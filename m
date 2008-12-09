From: David Miller <davem@davemloft.net>
Subject: Re: lowpri - RTO for unidirectional reciever
Date: Tue, 09 Dec 2008 13:43:22 -0800 (PST)
Message-ID: <20081209.134322.143704165.davem@davemloft.net>
References: <493DD199.6080600@hp.com>
	<20081208.235622.149344934.davem@davemloft.net>
	<493EC61F.7090806@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753841AbYLIVnV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 16:43:21 -0500
In-Reply-To: <493EC61F.7090806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 09 Dec 2008 11:25:19 -0800

> A miracle occurs going from zero bytes of payload but several bytes
> of TCP options (scale and MSS) to having one byte of payload and no
> bytes of options? (Timestamp options remaining the same in both
> cases)

All it takes is ~40 bytes on an extremely slow link.
