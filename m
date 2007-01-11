From: Steve Hill <steve.hill@dialogic.com>
Subject: Re: Fw: Intermittent SCTP multihoming breakage
Date: Thu, 11 Jan 2007 10:10:03 +0000
Message-ID: <Pine.CYG.4.58.0701111007010.5484@shill1-mobl.eicon.com>
References: <20070103154634.b40d9cde.akpm@osdl.org>
 <1167872389.8646.25.camel@w-sridhar2.beaverton.ibm.com>
 <Pine.CYG.4.58.0701040913300.3128@shill1-mobl.eicon.com>
 <1168459812.8248.24.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eiconmtl.eicon.com ([192.219.17.124]:39447 "EHLO
	EICONMTL.eicon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030250AbXAKKJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jan 2007 05:09:23 -0500
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1168459812.8248.24.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Jan 2007, Sridhar Samudrala wrote:

> So looks like there may be an issue with PR-SCTP(partial reliability)
> support and packet loss. I will take a look into this.
>
> Do you still see this problem even if you don't set timetolive?

No, the problem seems to go away if the timetolive is set to 0, so this is
what I have now done since I had not intended to set the timetolive in the
first place (but I thought it was still worth posting details of the
problem since it does appear to be a bug).

-- 
 - Steve Hill
   Software Engineer
   Dialogic
   Fordingbridge, Hampshire, UK
   +44-1425-651392
   steve.hill@dialogic.com
