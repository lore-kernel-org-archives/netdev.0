From: Michal Ludvig <michal@logix.cz>
Subject: Re: [Ipsec-tools-devel] ipv4/ipv6 forwarding check
Date: Fri, 29 Oct 2004 11:27:38 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410291120590.12450@maxipes.logix.cz>
References: <200410300506.i9U56Yse005815@faith.austin.ibm.com>
 <4181EBC3.3020507@gmc.lt>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joy Latten <latten@austin.ibm.com>,
        ipsec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Aidas Kasparas <a.kasparas@gmc.lt>
In-Reply-To: <4181EBC3.3020507@gmc.lt>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 29 Oct 2004, Aidas Kasparas wrote:

> 1) push kernel developers to have rfc2401 semantics in kernel;
> 1a) have pfkey kernel part transform rfc2401 semantics into kernel 
> semantics;
> 2) have libpfkey generate extra policies transparently to the user;
> 3) have tools (setkey and racoon) generate extra policies
> transparently to the user;
> 4) extend setkey's syntax to make explicit forward policy management
> possible and write docs for all the admins to change policies.

At least we must provide #4 - now it doesn't work at all, with explicit 
fwd policies things could be set up in most cases except for policy 
autogeneration in racoon. 

I hope to do the setkey part today.

Michal Ludvig
-- 
* A mouse is a device used to point at the xterm you want to type in.
* Personal homepage - http://www.logix.cz/michal
