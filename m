From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] make lock/release_sock fast calls
Date: Wed, 31 Mar 2004 23:07:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331230717.27c77994.davem@redhat.com>
References: <20040331112407.66309027@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040331112407.66309027@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 31 Mar 2004 11:24:07 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> lock_sock and release_sock are no longer inline, but they are called in
> the critical path of many operations, so it makes sense to use register based
> fastcall.

I think I'll add this change when 2.6.6 opens up.

Someone haggled about CONFIG_REGPARM, but that argument is crap.
We have "FASTCALL()" for a reason, and CONFIG_REGPARM does not
obviate it.
