From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 08:34:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819083438.26c985b9.davem@redhat.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB57@post.pc.aspectgroup.co.uk>
	<070c01c36653$7f3c1ab0$c801a8c0@llewella>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: richard@aspectgroup.co.uk, skraw@ithnet.com, willy@w.ods.org,
   alan@lxorguk.ukuu.org.uk, carlosev@newipnet.com, lamont@scriptkiddie.org,
   davidsen@tmr.com, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Bas Bloemsaat" <bloemsaa@xs4all.nl>
In-Reply-To: <070c01c36653$7f3c1ab0$c801a8c0@llewella>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 15:11:59 +0200
"Bas Bloemsaat" <bloemsaa@xs4all.nl> wrote:

> It it doesn't define a standard either, but makes
> perfectly clear that any interface has it's own ARP,
> not one ARP for the entire system.

This is absolutely not true.

There are two valid ways the RFCs allow systems to handle
IP addresses.

1) IP addresses are owned by "the host"
2) IP addresses are owned by "the interface"

Linux does #1, many systems do #2, both are correct.

We provide ways for you to obtain the behavior or #2
so there is nothing to complain about.
