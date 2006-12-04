From: Paul Collins <paul@briny.ondioline.org>
Subject: Re: NETDEV-BCM43XX BUG - Failure to associate AP with latest devscape git pull..
Date: Tue, 05 Dec 2006 12:50:25 +1300
Message-ID: <87ac231ari.fsf@briny.internal.ondioline.org>
References: <45733FBF.5020800@gmail.com>
	<87y7pogj1k.fsf@briny.internal.ondioline.org>
	<45745D2B.1090700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from jenny.ondioline.org ([66.220.1.122]:4424 "EHLO
	jenny.ondioline.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937167AbWLDXyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Dec 2006 18:54:12 -0500
To: Robert Martin <robertm83@gmail.com>
In-Reply-To: <45745D2B.1090700@gmail.com> (Robert Martin's message of "Mon\, 04
	Dec 2006 12\:38\:51 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert Martin <robertm83@gmail.com> writes:

> Paul Collins wrote:
>> I started playing with wireless-dev's bcm43xx-d80211 recently and
>> noticed that I had to set the frequency manually.  When I did that,
>> setting the ap manually caused the card to associate immediately.
>
> Alas, that seems to have been the problem, I was getting different
> frequencies.  Once I manually set the frequency, dhclient worked
> perfectly.  The only problem now is that I seem to be limited to very
> slow speeds (on the order of 5-20K/s, or ~120 kilobits/s).

I guess the speed problem is due to the general state of BCM4318
support, as mentioned by the developers.

I'm glad the frequency thing isn't some weird glitch that only I am
experiencing though.

-- 
Paul Collins
Wellington, New Zealand

Dag vijandelijk luchtschip de huismeester is dood
