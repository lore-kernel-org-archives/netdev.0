From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PATCH: ethtool power manglement hooks
Date: Tue, 08 Jun 2004 14:02:43 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40C5FF43.1090805@pobox.com>
References: <20040607155018.GA5810@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S265276AbUFHSDa@vger.kernel.org>
To: Alan Cox <alan@redhat.com>
In-Reply-To: <20040607155018.GA5810@devserv.devel.redhat.com>
List-Id: netdev.vger.kernel.org

Alan Cox wrote:
> Several ethernet drivers have been broken by the ethtool support because
> the ioctl code used to power the interface up and down as needed. Rather


To be more specific, the new ethtool_ops feature bypasses code in net 
drivers which did one of two things:
* power up the hardware, perform the ioctl, and power down the hardware
	or
* fail if netif_running() is false, indicating the driver's requirement 
that MII and ethtool operations only occur when the interface is up 
(thereby ignoring the power management issues)


Also, CC net driver patches to me and netdev, pretty please with sugar 
on it.

	Jeff
