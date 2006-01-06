From: Feyd <feyd@seznam.cz>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Fri, 06 Jan 2006 17:12:10 +0100
Message-ID: <43BE96DA.1020107@seznam.cz>
References: <1136541243.4037.18.camel@localhost> <200601061200.59376.mbuesch@freenet.de> <1136547494.7429.72.camel@localhost> <200601061245.55978.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>, jgarzik@pobox.com,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751599AbWAFQMI@vger.kernel.org>
To: Michael Buesch <mbuesch@freenet.de>
In-Reply-To: <200601061245.55978.mbuesch@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> The _real_ main point I wanted to make was to _not_ use a net_device for
> the master device. What else should be used for master device, let it
> be a device node or a netlink socket, is rather unimportant at
> this stage.

If the only purpose of the master device was configuration, then it
would be beter to use something other then a net_device, but you may
want to send/receive raw 802.11 packets from userspace, most logicaly
over a master interface.

Feyd
