From: "Nick Kossifidis" <mickflemm@gmail.com>
Subject: Re: [PATCH 5/5] Net: ath5k, kconfig changes
Date: Fri, 31 Aug 2007 01:18:31 +0300
Message-ID: <40f31dec0708301518u5ef32d13jfe1cce09656bf77d@mail.gmail.com>
References: <2713029743177393055@pripojeni.net>
	 <280951420471148977@pripojeni.net>
	 <20070828171330.GD29343@infradead.org>
	 <40f31dec0708291838p5d33eb34p3b4432d9d270841a@mail.gmail.com>
	 <20070830123609.GA5140@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Christoph Hellwig" <hch@infradead.org>,
	"Jiri Slaby" <jirislaby@gmail.com>, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:39125 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758891AbXH3WSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2007 18:18:32 -0400
Received: by py-out-1112.google.com with SMTP id u77so3112531pyb
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 15:18:32 -0700 (PDT)
In-Reply-To: <20070830123609.GA5140@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/8/30, John W. Linville <linville@tuxdriver.com>:
> On Thu, Aug 30, 2007 at 04:38:09AM +0300, Nick Kossifidis wrote:
> > 2007/8/28, Christoph Hellwig <hch@infradead.org>:
>
> > > Also this whole patch seems rather pointless.  It saves only
> > > very little and turns the driver into a complete ifdef maze.
>
> > Also most
> > people will use 5212 code only, 5211 cards are on some old laptops and
> > 5210, well i couldn't even find  a 5210 for actual testing :P
>
> FWIW, I'd bet dollars to donuts that distros will enable them all
> together.
>
> Is saving code space the only reason to turn these off?  How much
> space do you save?
>
> Is there some way you can isolate and/or limit the number of ifdef
> blocks further?  If so, we might consider a version of this patch
> that depends on EMBEDDED or somesuch...?
>
> John

O.K. as a first step i'll limit 5210 code only then, just an option
like "support older 5210 chipsets" which is going to be off by default
instead of 3 options. It's not just saving space, it's also saving
some runtime checks. It's not really a gain in performance though,
most checks are done during initialization and dfs setup, i just
thought it would be usefull to save as much cpu as possible.

-- 
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
