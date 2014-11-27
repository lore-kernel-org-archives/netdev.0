From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: Re: Is this 32-bit NCM?
Date: Thu, 27 Nov 2014 10:45:59 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411271037050.9464@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: youtux@gmail.com, alexxst@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:61521 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbaK0Jpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 04:45:31 -0500
In-Reply-To: <87ppc957h1.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok - we can arrive to some ocnclusions regarding the E3272.
First of all - the modem seems buggy enough to not be able to handle requests 
for different formats. You need to unplug and re-plug it, but this is onlyan 
impression and is reasonable.

Then - the modem will accept to ndisdup the connection with
at^ndisdup=1,1,"internet"
but - if we use huawei_cdc_ncm + cdc_ncm we have no flow handling messages and 
the modem stops here.
If we use the cdc_ncm 32-bit driver (modified) we get lotfs of
^dsflorpt
that's how it should be.
So I think we can say that something is changing.
Then there's the alignment problem you mentioned in your previous reply. And 
this is hard to solve.
could you try to help me understand where the problem is?
I feel like we are very close to the solution but something isn't working.
Or might be just try to change the 16 bit driver?

http://www.gstorm.eu/cdc_ncm.c
