From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix tuntap oversight
Date: Mon, 12 Apr 2004 10:58:55 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040412105855.37ec2162.davem@redhat.com>
References: <20040412065947.GC18810@net-ronin.org>
	<20040412001551.05476658.davem@redhat.com>
	<20040412162916.GA5046@net-ronin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeremy Martin <martinjd@csc.uvic.ca>
In-Reply-To: <20040412162916.GA5046@net-ronin.org>
List-Id: netdev.vger.kernel.org

On Mon, 12 Apr 2004 09:29:16 -0700
Jeremy Martin <martinjd@csc.uvic.ca> wrote:

> all use that netif_running() check when setting the MAC.  I actually just pulled
> the function from net_init.c for the tun change.  Are these broken?

Yes.
