From: Werner Almesberger <wa@almesberger.net>
Subject: Re: tc lockup on 2.4.19 up
Date: Mon, 8 Jul 2002 18:28:45 -0300
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020708182845.P1424@almesberger.net>
References: <20020708204858.GA16318@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20020708204858.GA16318@outpost.ds9a.nl>; from ahu@ds9a.nl on Mon, Jul 08, 2002 at 10:48:58PM +0200
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> I think the rule gets matched circularly, but I'm unsure. 

Indeed. Happens with tcsim too.

I need to think a bit about this one. As a work-around, you can use
tcc with -One, which generates a bunch of tests for equality instead
of the single negation.

Thanks,
- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://icapeople.epfl.ch/almesber/_____________________________________/
