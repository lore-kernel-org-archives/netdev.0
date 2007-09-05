From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
	condition
Date: Wed, 05 Sep 2007 08:33:39 -0400
Message-ID: <1188995619.4238.5.camel@localhost>
References: <20070904032036.GA11153@ludhiana>
	 <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org>
	 <20070905074411.GA4815@ludhiana>  <46DE9B09.7060603@katalix.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mandeep Singh Baines <mandeep.baines@gmail.com>,
	Daniele Venzano <venza@brownhat.org>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:48753 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753972AbXIEMdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 08:33:46 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2095799wxd
        for <netdev@vger.kernel.org>; Wed, 05 Sep 2007 05:33:46 -0700 (PDT)
In-Reply-To: <46DE9B09.7060603@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-09 at 13:03 +0100, James Chapman wrote:

> I have a patch that solves the high interrupt rate problem by keeping 
> the driver in polled mode longer. It's written for the latest NAPI 
> version that DaveM posted recently. I'll try to get some time to write 
> it up and post it for comment.

Theres interesting challenges to be tackled with resolving that. 
Just so you dont reinvent the wheel or to help invent a better one;
please read:
http://kernel.org/pub/linux/kernel/people/hadi/docs/UKUUG2005.pdf

if you have, what are the differences in your approach - and when
do you find it useful?

cheers,
jamal

PS:- Mandeep, i was going to suggest thresholds but you beat me to it
with your latest patch.

