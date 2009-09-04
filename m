From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH NEXT 1/3] netxen: fix lro buffer allocation
Date: Thu, 3 Sep 2009 20:14:01 -0700
Message-ID: <7608421F3572AB4292BB2532AE89D565865FA8A556@AVEXMB1.qlogic.org>
References: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
 <20090903.200615.220020629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.com" <davem@davemloft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39139 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932570AbZIDDOF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:14:05 -0400
In-Reply-To: <20090903.200615.220020629.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> Applied.  But allocating such huge linear buffers is asking for
> guarenteed trouble.  Can't you split them up into page sized chunks
> with this chip?

"chained" LRO is not enabled by firmware. Contiguous LRO requires
fewer commands (internal) from firmware to DMA engines.

-Dhananjay