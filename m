From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros, recursive
 vsnprintf
Date: Sat, 6 Mar 2010 15:46:45 -0800 (PST)
Message-ID: <alpine.LFD.2.00.1003061540470.23804@localhost.localdomain>
References: <cover.1267682641.git.joe@perches.com>  <20100304143837.af39845d.akpm@linux-foundation.org>  <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>  <1267911399.849.39.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
  <1267914654.849.81.camel@Joe-Laptop.home>  <alpine.LFD.2.00.1003061445490.31447@localhost.localdomain>  <alpine.LFD.2.00.1003061455590.31447@localhost.localdomain> <1267918554.849.89.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1267918554.849.89.camel@Joe-Laptop.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 6 Mar 2010, Joe Perches wrote:
> 
> I believe 32 bits isn't possible.
> 
> type:6
> flags:8
> width:8
> base:6
> precision:6
> qualifier:8

type: 5
flags: 7
width: 5 (make it 6 bits and signed)
base: 5
precision: 5 (make it 6 bits, and signed)
qualifier: 3

Now, admittedly, right now 'qualifier' really has to be 8, but that's just 
because we use an ASCII character for it. But I don't think there are more 
than 8 actual legal qualifiers. And 'base' could be just 2 bits, since 
there are only a couple of legal bases, but I left room for them all 
anyway.

And the other really should fit in those numbers unchanged, I think. 

			Linus
