From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: IPv6 route buffer space problem
Date: Fri, 19 Nov 2004 19:21:48 -0200
Message-ID: <419E63EC.4050501@conectiva.com.br>
References: <20041119175924.M79505@coredumps.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gianluca <gianluca@linux.it>
In-Reply-To: <20041119175924.M79505@coredumps.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Gianluca wrote:
> Hi, i have a problem when i add more than 500/540 sit interfaces on my linux 
> box (debian), if i add a new interface (with iptunnel and ifconfig) i 
> haven't errors but when i add a new router for the interface i have this 
> error "No buffer space available".
> I had search on /proc for increment the buffer but i dont have found 
> anythink, i think that i need to modify the kernel sources.
> Please help me.

Humm, time to look at the relevant codepaths and find some bogus return
-ENOBUFS?

What kernel version exactly?

- Arnaldo
