From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND][PATCH] [NET_SCHED]make qdisc_restart more readable
Date: Thu, 24 May 2007 18:13:54 +0200
Message-ID: <4655B9C2.4050200@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902E7C23A@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, xma@us.ibm.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36853 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbXEXQOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 12:14:07 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902E7C23A@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>>sigh. 
>>I wont be able to do this change until tonight or tommorow 
>>morning. I think the process i am using to re-generate 
>>patches maybe too consuming?
>>Maybe you could offer some advice. Heres what i do:
>>1. clone Daves latest tree localy
>>2. clone another tree from that
>>3. create patch on second clone
>>4. compile; test;compile;test until looks reasonable 5. 
>>commit with the comments 6. submit 7. build other patches on 
>>top (example batching in this case) 8. feedback on patch 
>>comes back 9. Re-do steps #2-#6
>>
>>My steps #2-#6 are expensive; is there a way to optimize that process?
> 
> 
> [..]
> 
> One tree, multiple branches, very quick to move between them, low
> overhead.  If this works for you, also look at stacked GIT (stg) for
> pushing and popping patches from your tree - very handy.


I have also found that stgit is a huge time saver, especially for
making changes to patches or when dealing with many patches with
interdependencies.

