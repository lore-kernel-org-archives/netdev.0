From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCHv2 net-next 0/4] Small fix for TCP PMTU
Date: Thu, 26 Feb 2015 13:40:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAEEABA@AcuExch.aculab.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
 <1424922566-6787-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "edumazet@google.com" <edumazet@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"fengyuleidian0615@gmail.com" <fengyuleidian0615@gmail.com>
To: 'Fan Du' <fan.du@intel.com>,
	"johnwheffner@gmail.com" <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.182]:57317 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753259AbbBZNle convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 08:41:34 -0500
In-Reply-To: <1424922566-6787-1-git-send-email-fan.du@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du
> This patchset performs some small fix and enhancement
> for current TCP PMTU as per RFC4821 with below changes:
> 
> Patch1/4: Set probe mss base to 1024 Bytes per RFC4821
> Patch2/4: Do not double probe_size for each probing,
>           use a simple binary search to gain maximum performance.
> Patch3/4: When it comes to blackhole detection, shrink current
> 	  mss for next probing.
> Patch4/4: Create a probe timer to detect enlarged path MTU.

Isn't the most likely problem PPPoE blackholes?
Where a reduction of the PMTU from 1500 to (IIRC) 1492 is
all that is required?

Would seem appropriate to test that value reasonable quickly.

	David
