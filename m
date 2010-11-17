From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v3] filter: Optimize instruction revalidation code.
Date: Wed, 17 Nov 2010 10:01:56 +0100
Message-ID: <fb1f2f80c2a0663226799d4fa345d0f8@localhost>
References: <20101110.102129.112602843.davem@davemloft.net>
 <1289414024.2469.20.camel@edumazet-laptop>
 <20101110.103807.39173013.davem@davemloft.net>
 <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
 <1289915053.5372.183.camel@edumazet-laptop>
 <201011162331.CGH00026.OFOSFVMFQtLHOJ@I-love.SAKURA.ne.jp>
 <1289925055.5372.484.camel@edumazet-laptop>
 <201011170119.oAH1JpES011121@www262.sakura.ne.jp>
 <1289980137.2732.280.camel@edumazet-laptop>
 <201011170806.oAH86AdI013337@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <eric.dumazet@gmail.com>, <mjt@tls.msk.ru>, <davem@davemloft.net>,
	<drosenberg@vsecurity.com>, <xiaosuo@gmail.com>,
	<netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:50093 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758221Ab0KQJB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 04:01:58 -0500
In-Reply-To: <201011170806.oAH86AdI013337@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 17 Nov 2010 17:06:10 +0900, Tetsuo Handawrote:



> If compilers can generate better code for continuous case values

> than discontinuous case values, then keeping BPF_S_* makes sense.



Yes, this is crucial. A compiler cannot generate a jump table of O(1) for

dense labels. The BPF_S_* translation was done to convert to a dense label

construct. So this "optimization" is a no-go.



Look at the log and read my comment for a detailed explanation.



Anyway: "code--" increments the _copied_ value, not the value in the

evaluated opcode itself. I will validate the patch!



Hagen
