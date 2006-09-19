From: Andi Kleen <ak@suse.de>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 07:55:03 +0200
Message-ID: <200609190755.03713.ak@suse.de>
References: <20060918162847.GA4863@ms2.inr.ac.ru> <20060918210321.GA4780@ms2.inr.ac.ru> <20060918.142247.14844785.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, master@sectorb.msk.ru, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:54949 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1751162AbWISFzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 01:55:50 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060918.142247.14844785.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 18 September 2006 23:22, David Miller wrote:

> Ok, ok, but don't we have queueing disciplines that need the timestamp
> even on ingress?

I grepped and I can't find any. The only non SIOCGTSTAMP users of the
time stamp seem to be sunrpc and conntrack and I bet both can be converted
over to jiffies without trouble.

-Andi
