From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros, recursive
 vsnprintf
Date: Sat, 6 Mar 2010 14:57:46 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain>
References: <cover.1267682641.git.joe@perches.com>  <20100304143837.af39845d.akpm@linux-foundation.org>  <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>  <1267911399.849.39.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
 <1267914654.849.81.camel@Joe-Laptop.home> <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 6 Mar 2010, Linus Torvalds wrote:
> 
> I'm not convinced. We pass that 'printf_spec' around a lot, including 
> nesting. Not as a pointer, either.

Btw, I wonder if those fields could become bitfields, or 'unsigned char' 
etc. That printf_spec really is unnecessarily big. It should _easily_ fit 
in a single register on a 64-bit platform, possibly even a 32-bit one (we 
could limit field width and precision to 5 bits, for example)

			Linus
