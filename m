From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 1/2] IPv6: stricter checks on link-locals in bind and
 sendmsg
Date: Mon, 19 Jan 2004 21:33:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040119213350.725dcee4.davem@redhat.com>
References: <Pine.LNX.4.58.0401140959270.23925@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.58.0401140959270.23925@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 14 Jan 2004 10:35:11 +0200 (EET)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> I found a couple of suspected bugs related to (source) address
> handling while rummaging around the code...
> 
> When binding to a link-local address, inet6_bind() and raw6_bind() only
> check that an interface is specified and that the address exists, but
> they don't check if it actually exists on the specified interface.
> 
> Similarly, in datagram_sent_ctl() we don't check for the possibility of a
> link-local address when we receive the source address from userspace.

Applied, thanks Ville.
