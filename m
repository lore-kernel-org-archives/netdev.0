From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] Add missing skb->dev assignment in Frame Relay RX code
Date: Fri, 04 Jul 2008 14:39:22 +0200
Message-ID: <m3bq1dzuv9.fsf@maximus.localdomain>
References: <m3wsk8aupw.fsf@maximus.localdomain> <486E1404.8090704@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:52037 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351AbYGDMjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:39:23 -0400
In-Reply-To: <486E1404.8090704@garzik.org> (Jeff Garzik's message of "Fri\, 04 Jul 2008 08\:13\:56 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik <jeff@garzik.org> writes:

>> Commit 4c13eb6657fe9ef7b4dc8f1a405c902e9e5234e0 ([ETH]: Make
>> eth_type_trans set skb->dev like the other *_type_trans) removed
>> skb->dev assignment from hdlc_fr.c:fr_rx(). Unfortunately it was also
>> needed for cases other than eth_type_trans().
>>
>> Adding it back.

> applied

Thanks.
-- 
Krzysztof Halasa
