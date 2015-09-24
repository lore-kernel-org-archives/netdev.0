From: Phil Sutter <phil@nwl.cc>
Subject: Re: RFC: ss: improve horizontal output scaling
Date: Thu, 24 Sep 2015 15:32:16 +0200
Message-ID: <20150924133216.GC26600@orbit.nwl.cc>
References: <20150924111650.GY24212@orbit.nwl.cc>
 <1443097547.29850.159.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150924123615.GB26600@orbit.nwl.cc>
 <1443101279.29850.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38850 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753867AbbIXNcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 09:32:18 -0400
Content-Disposition: inline
In-Reply-To: <1443101279.29850.162.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2015 at 06:27:59AM -0700, Eric Dumazet wrote:
> On Thu, 2015-09-24 at 14:36 +0200, Phil Sutter wrote:
> 
> > This is because TIOCGWINSZ returns 80 if the output is a pipe. 
> 
> Not exactly.
> 
> ss doesn't even call TIOCGWINSZ if output is a pipe.

Oh, you're absolutely right of course. Obviously, since STDOUT_FILENO
does not refer to a terminal, isatty() returns false.

Thanks, Phil
