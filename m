From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues
 default 8 queues
Date: Sun, 17 Jun 2012 12:31:28 +0300
Message-ID: <1339925488.2486.2.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1339916031.2486.0.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120617.010817.1214320083280899562.davem@davemloft.net>
 <1339922036.2486.1.camel@lb-tlvb-eilong.il.broadcom.com>
 <20120617.020058.2281757592609638666.davem@davemloft.net>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: meravs@broadcom.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3809 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199Ab2FQJbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jun 2012 05:31:40 -0400
In-Reply-To: <20120617.020058.2281757592609638666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-06-17 at 02:00 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Sun, 17 Jun 2012 11:33:56 +0300
> 
> > drivers now, it does not sound like a good path - so I was asking if you
> > can consider a kernel parameter as acceptable path. To be clear, I'm
> > asking if adding the default for all multi-queue drivers in the form of
> > a kernel parameter is a good path to explore.
> 
> If it's the default, there's no need for a kernel command line
> parameter.  Those suck, just pick a good default.
> 

OK. So we will send an RFC series setting the default (hard coded
define) to 8 for all multi-queue drivers and that will start a
discussion if this is a good default number or not. The side-effect of
this series will be that drivers that did not implement set_channels
will not be able to change this default back to the HW limit like they
run today (assuming the HW limit is higher than the chosen default).

On top of that, we will send this series for the bnx2x again without any
default -allowing up to 64 queues unless set_channels is used.

Eilon
