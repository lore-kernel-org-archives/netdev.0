From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 18 Sep 2006 00:39:38 -0700 (PDT)
Message-ID: <20060918.003938.26278728.davem@davemloft.net>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
	<20060904160045.GA15599@ms2.inr.ac.ru>
	<44FDBA04.3080104@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:39870
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751567AbWIRHjj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:39:39 -0400
To: rick.jones2@hp.com
In-Reply-To: <44FDBA04.3080104@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 05 Sep 2006 10:55:16 -0700

> Is this really necessary?  I thought that the problems with ABC were in 
> trying to apply byte-based heuristics from the RFC(s) to a 
> packet-oritented cwnd in the stack?

This is receiver side, and helps a sender who does congestion
control based upon packet counting like Linux does.   It really
is less related to ABC than Alexey implies, we've always had
this kind of problem as I mentioned in previous talks in the
past on this issue.
