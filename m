From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] declance: Fix 64-bit compilation warnings
Date: Sat, 05 Jul 2014 09:07:00 -0700
Message-ID: <1404576420.6384.41.camel@joe-AO725>
References: <alpine.LFD.2.11.1406290246120.15455@eddie.linux-mips.org>
	 <20140702.182807.1245632778216212860.davem@davemloft.net>
	 <alpine.LFD.2.11.1407030244230.15455@eddie.linux-mips.org>
	 <alpine.LFD.2.11.1407030331550.15455@eddie.linux-mips.org>
	 <1404356734.14741.18.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030423300.15455@eddie.linux-mips.org>
	 <1404364565.14741.26.camel@joe-AO725>
	 <alpine.LFD.2.11.1407030637030.15455@eddie.linux-mips.org>
	 <1404368746.14741.36.camel@joe-AO725>
	 <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Maciej W. Rozycki" <macro@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0112.hostedemail.com ([216.40.44.112]:59206 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752327AbaGEQHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 12:07:05 -0400
In-Reply-To: <alpine.LFD.2.11.1407051529040.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-07-05 at 15:56 +0100, Maciej W. Rozycki wrote:
>  One question though, does either of you or anybody else know why we're 
> inconsistent about this 0x prefixing of virtual addresses vs physical 
> addresses?  Specifically %p vs e.g. %pad.

I think it's a mistake and I agree.

I submitted a patch to remove the prefix from %pad.

https://lkml.org/lkml/2014/3/21/333
