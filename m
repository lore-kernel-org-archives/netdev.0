From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Wed, 24 Aug 2005 05:50:11 +0200
Message-ID: <17163.61043.912047.611487@robur.slu.se>
References: <20050815213855.GA17832@netnation.com>
	<43014E27.1070104@cosmosbay.com>
	<20050823190852.GA20794@netnation.com>
	<17163.32645.202453.145416@robur.slu.se>
	<20050824000158.GA8137@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050824000158.GA8137@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Simon Kirby writes:

 > Something is definitely broken here.  Are the interrupts (or in this
 > case, NAPI) able to starve the gc somehow?

 Hmm no in 2.6 dst entries are freed via RCU callback this had problems
 but was redesigned.

 Reading your old email... Didn't you get "dst cache overflow" before
 2.6.11-bk2?

 In other case I like to have your detailed setup to see if I get any
 idea or possible can reproduced.

 Cheers.
					--ro
 
