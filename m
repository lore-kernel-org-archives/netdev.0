From: Dan Williams <dcbw@redhat.com>
Subject: Re: adm8211 (from linville wireless-2.6) in xen guest
Date: Tue, 23 Jan 2007 10:20:27 -0500
Message-ID: <1169565627.2777.16.camel@localhost.localdomain>
References: <45B208DA.8010807@caiway.nl>
	 <200701221430.50547.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jan Evert van Grootheest <j.e.van.grootheest@caiway.nl>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:51754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751977AbXAWPRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 10:17:55 -0500
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200701221430.50547.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-22 at 14:30 -0500, Michael Wu wrote:
> On Saturday 20 January 2007 07:19, Jan Evert van Grootheest wrote:
> > Hi,
> >
> > Just writing to thank all of you that made the adm8211 driver in John
> > Linvilles wireless-2.6 development tree (not the dscape one, which I
> > will try also).
> >
> CC me then. :) Note that I only maintain the d80211 based adm8211 driver now, 
> but that driver doesn't have adhoc support yet.
> 
> > One question, though. I'm trying to use it in ad-hoc mode. If there's no
> > other station with the same essid, it just keeps mentioning that
> > (besides the BCNTC and TSFTF messages)
> >
> > wlan0: No matching adhoc sta found. Creating IBSS 00:04:e2:3f:2a:70 CHAN=11
> >
> > And the IBSS changes every time, which is about every 30 seconds. Is it
> > really supposed to change the IBSS each time?
> Probably not, but I never debugged adhoc mode enough.
> 
> > The reason I ask is that my wife has a laptop with an Atheros chip in
> > it. If it is configured for ad-hoc it creates the IBSS and sticks with
> > it. So I now have two computers that have different behaviour in this
> > respect. That in itself is not, I guess, a problem. But it seems to me
> > that the random IBSS created by the adm8211 would result in two stations
> > not seeing eachother or taking longer than necessary to find eachother?
> >
> Have you checked? I think the bssid should stop changing once another station 
> with the same ssid comes into range.

Hmm; that's odd.  If the card is set to adhoc mode and it cannot find
another station, then it should just start up as the only station in the
adhoc network.  It ideally shouldn't be searching for another one since
of course you don't really need more than one STA to form an adhoc
network.

In any case, concentration should go into the d80211 version of
course :)

Dan

> > And one more question that I don't understand... the wlan0 interface
> > does not appear in snmp queries. Any idea about that?
> >
> Nope.
> 
> -Michael Wu

