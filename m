From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Mark SIOCSIFNAME as compatible ioctl
Date: Tue, 13 Jan 2004 15:01:44 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113150144.1f8e214c.davem@redhat.com>
References: <20040108070413.GA31778@averell>
	<20040109020456.045b447e.davem@redhat.com>
	<20040109165627.2e0845af.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040109165627.2e0845af.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 9 Jan 2004 16:56:27 +0100
Andi Kleen <ak@suse.de> wrote:

> On Fri, 9 Jan 2004 02:04:56 -0800
> "David S. Miller" <davem@redhat.com> wrote:
> 
> > How can we mark it compatible?  It needs the stuff dev_ifname32() in
> > fs/compat_ioctl.c does for SIOCGIFNAME doesn't it?
> 
> It takes two strings. This should be compatible:

You're absolutely right Andi, thanks.

Patch applied.
