From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Wed, 16 May 2007 22:12:47 -0400
Message-ID: <1179367968.4084.27.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>
	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>
	 <4645F325.3060607@trash.net>  <1178999773.15622.44.camel@localhost>
	 <1179066518.15622.60.camel@localhost> <1179149418.15622.79.camel@localhost>
	 <1179356104.4084.23.camel@localhost>
	 <1179357351.10414.18.camel@w-sridhar2.beaverton.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:41452 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757793AbXEQCMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 22:12:52 -0400
Received: by wx-out-0506.google.com with SMTP id h31so395153wxd
        for <netdev@vger.kernel.org>; Wed, 16 May 2007 19:12:52 -0700 (PDT)
In-Reply-To: <1179357351.10414.18.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-16-05 at 16:15 -0700, Sridhar Samudrala wrote:

> 
> I think your qdisc_restart() cleanup patch is OK. There you are
> still calling dev_hard_start_xmit() and GSO should work fine.


Sorry, you are right - I thought i cutnpasted from it.
So Dave, false alarm ;-> That patch is clean.

> But the batch xmit patch has some issues.

I will resubmit that. I nheed to think about it a little.
It should work fine as is if no GSO or nit.

cheers,
jamal

