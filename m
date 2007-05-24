From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [RESEND][PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Thu, 24 May 2007 08:48:40 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902E7C23A@orsmsx414.amr.corp.intel.com>
References: <1180013913.4092.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>,
	"Thomas Graf" <tgraf@suug.ch>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	<netdev@vger.kernel.org>, "Sridhar Samudrala" <sri@us.ibm.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Krishna Kumar2" <krkumar2@in.ibm.com>, <xma@us.ibm.com>
To: <hadi@cyberus.ca>, "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:6285 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbXEXPsq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 11:48:46 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1180013913.4092.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> sigh. 
> I wont be able to do this change until tonight or tommorow 
> morning. I think the process i am using to re-generate 
> patches maybe too consuming?
> Maybe you could offer some advice. Heres what i do:
> 1. clone Daves latest tree localy
> 2. clone another tree from that
> 3. create patch on second clone
> 4. compile; test;compile;test until looks reasonable 5. 
> commit with the comments 6. submit 7. build other patches on 
> top (example batching in this case) 8. feedback on patch 
> comes back 9. Re-do steps #2-#6
> 
> My steps #2-#6 are expensive; is there a way to optimize that process?

1. clone Dave's tree
2. cd into said tree
3. git branch qdiscpatch
4. create patches
5. compile; test; compile until looks reasonable
6. git commit -a
7. git diff (generate patches)
8. git branch batching
9. rinse/repeat 4-7

One tree, multiple branches, very quick to move between them, low
overhead.  If this works for you, also look at stacked GIT (stg) for
pushing and popping patches from your tree - very handy.

Thanks,

-PJ
