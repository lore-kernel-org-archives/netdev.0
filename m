From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] pkt_cls.h incompatiables
Date: Thu, 22 Jul 2004 13:53:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040722135339.181321b1.davem@redhat.com>
References: <200407161544.59342.arekm@pld-linux.org>
	<20040716103759.1928c2ae@dell_ss3.pdx.osdl.net>
	<200407172357.15832.arekm@pld-linux.org>
	<20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@znyx.com, arekm@pld-linux.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040722134522.4e7e0b07@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 22 Jul 2004 13:45:22 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The recent changes to (6 Jul 04) pkt_cls.h are evil, you can't build a version
> of 'tc' to work unless you know the kernel config!
> 
> It has several API problems:
>   - API data structures change on kernel config options
>   - new fields should be added at the end of a structure to allow
>     binary compatibility.
>  
> This patch tries to clean this up.

I totally agree and I've discussed this with Jamal already.
We just haven't gotten around to coding up the patch, but
now you have :-)

I'll apply this, thanks Stephen.
