From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/11) Irda dongle module owner support (revised)
Date: Fri, 3 Oct 2003 23:06:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003230606.6a35677e.davem@redhat.com>
References: <20031002152026.4bfd2c67.shemminger@osdl.org>
	<20031002233335.GA7945@bougret.hpl.hp.com>
	<20031003102133.2e5a41a2.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, jt@bougret.hpl.hp.com, irda-users@lists.sourceforge.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031003102133.2e5a41a2.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Oct 2003 10:21:33 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Revised version of the dongle module owner patch, incorporating Jean's comments.
> This replaces the original patch.  It provides an owner field an appropriate 
> ref counting for IRDA dongles.

I applied this, but where's the necessary IRDA header file change
that adds the 'owner' field to the dongle_reg structure?

It's missing from this patch.

Please send me that, and then I assume that I can just suck in all
of your individual IRDA driver patches from yesterday?
