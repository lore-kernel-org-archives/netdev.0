From: Daniele Lacamera <root@danielinux.net>
Subject: Re: TCP Pacing
Date: Wed, 13 Sep 2006 10:18:39 +0200
Message-ID: <200609131018.40023.root@danielinux.net>
References: <200609121958.22820.root@danielinux.net> <5640c7e00609121426t75f5519at562a85f40b64163@mail.gmail.com>
Reply-To: root@danielinux.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Carlo Caini" <ccaini@deis.unibo.it>,
	"Rosario Firrincieli" <rfirrincieli@arces.unibo.it>,
	"Giovanni Pau" <gpau@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:6661 "EHLO
	danielinux.vm.bytemark.co.uk") by vger.kernel.org with ESMTP
	id S1751699AbWIMISk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 04:18:40 -0400
To: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
In-Reply-To: <5640c7e00609121426t75f5519at562a85f40b64163@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 12 September 2006 23:26, Ian McDonald wrote:
> Where is the published research? If you are going to mention research
> you need URLs to papers and please put this in source code too so
> people can check.

I added the main reference to the code. I am going to give you all the 
pointers on this research, mainly recent congestion control proposals 
that include pacing.

> I agree with Arnaldo's comments and also would add I don't like having
> to select 1000 as HZ unit. Something is wrong if you need this as I
> can run higher resolution timers without having to do this....

I removed that select in Kconfig, I agree it doesn't make sense at all, 
for portability. However, pacing works with 1ms resolution, so maybe 
a "depends HZ_1000" is still required. (How do you run 1ms timers with 
HZ!=1000?)

Thanks

-- 
Daniele Lacamera
root@danielinux.net
