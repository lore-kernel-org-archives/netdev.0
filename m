From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] kill rtnl_exlock stubs
Date: Wed, 28 Jul 2004 18:59:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728185923.304bac86.davem@redhat.com>
References: <20040727095057.78c7419c@dell_ss3.pdx.osdl.net>
	<4106A132.8040207@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com, hadi@znyx.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4106A132.8040207@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2004 20:38:42 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Stephen Hemminger wrote:
> > Rtnetlink has some macro's that are relics from earlier locking.
> > They are only used a couple of places so are easy to kill.
> 
> The variable "exclusive" in rtnetlink_rcv_msg becomes useless with
> this patch. This patch (on top of Stephen's patch) removes it.

Both patches look fine, thanks guys.

I thought maybe Alexey might have had some fantastic
plan with exclusive locks, but this stuff has gone
beyond bitrot :-)
