From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.8-rc] tuntap: refuse to re-attach to different
 tun_struct
Date: Thu, 10 Jan 2013 14:39:02 -0800 (PST)
Message-ID: <20130110.143902.2166041015759450388.davem@davemloft.net>
References: <1357804788-19976-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stefanha@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357804788-19976-1-git-send-email-stefanha@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Thu, 10 Jan 2013 08:59:48 +0100

> Multiqueue tun devices support detaching a tun_file from its tun_struct
> and re-attaching at a later point in time.  This allows users to disable
> a specific queue temporarily.
> 
> ioctl(TUNSETIFF) allows the user to specify the network interface to
> attach by name.  This means the user can attempt to attach to interface
> "B" after detaching from interface "A".
> 
> The driver is not designed to support this so check we are re-attaching
> to the right tun_struct.  Failure to do so may lead to oops.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>

Applied.
