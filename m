From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding] compatibilty issues
Date: Mon, 29 Sep 2003 19:38:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F78C262.30109@pobox.com>
References: <20030929232534.GB93323@calma.pair.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Chad N. Tindel" <chad@tindel.net>
In-Reply-To: <20030929232534.GB93323@calma.pair.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chad N. Tindel wrote:
>>Not correct.  When I am testing patches people send to me, I am 
>>literally booting back and forth into 2.4 and 2.6 on an hour-by-hour 
>>basis.  2.4 ifenslave must continue to work under a 2.6 kernel.
> 
> 
> This directly contradicts what I was told by David Miller when we first
> integrated bonding into 2.4 back in the 2.4.9 timeframe.  So, what I would
> like from you then is a statement saying for how long this support must
> continue.  Does the 2.8 ifenslave have to work for 2.4?  Or is it simply
> an off by one problem?  That is, 2.8 ifenslave will have to work for 
> a 2.6 kernel as well, but no more?  

Well, if that's David's sentiment, then I respectfully disagree with that.

You need to be conscious of what installations are out there.  Most 
kernel maintainers, myself and David included, are currently maintaining 
both 2.4 and 2.6 support because that's what people are using. 
Eventually time will pass, and 2.4 will (essentially) go unmaintained, 
and the kernel maintainers will focus their attention on 2.6 stable 
series, and development for 2.7.

At the user end of things, people are for the most part running 
2.4.x-based stuff, with perhaps some early adventures into 2.6.  So you 
can see the _common_ case for the near future is supporting both 2.4 and 
2.6 out of the box.

I'm realistic.  I'm not advocating that you support 2.2 through 2.8 
kernels in the same binary.  What I'm talking about is common sense -- 
you see 2.4 and 2.6 mixing in the field.  As I said, that's the common 
case for the near future.

The common case should be supported.   :)

	Jeff
