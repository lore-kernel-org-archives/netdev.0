From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 1/3]: tg3: Consolidate two ->hard_start_xmit()
 handlers.
Date: Thu, 19 Jun 2008 06:55:57 -0700
Message-ID: <C27F8246C663564A84BB7AB343977242019B6FEC84@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20080619.041016.202137414.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "vinay@linux.vnet.ibm.com" <vinay@linux.vnet.ibm.com>,
	"krkumar2@in.ibm.com" <krkumar2@in.ibm.com>
To: "'David Miller'" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1398 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751035AbYFSN4g convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 09:56:36 -0400
In-Reply-To: <20080619.041016.202137414.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:

> tg3: Consolidate two ->hard_start_xmit() handlers.
>
> In order to facilitate making changes to the TX handling
> of this driver easier to implement, combine the two transmit
> handlers.
>
> One is for working around DMA bugs in various chip versions.
> This is replaced with a feature bit, which guards the DMA
> condition checks.

The TG3_FLG2_HW_TSO_2 logic also needs to be added back to the
consolidated hard_start_xmit() handler.  We'll send you an
updated patch 1 later today.

