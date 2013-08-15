From: David Miller <davem@davemloft.net>
Subject: Re: TCP Connection teardown seems to violate TCP specification
Date: Wed, 14 Aug 2013 17:19:16 -0700 (PDT)
Message-ID: <20130814.171916.338807326839447447.davem@davemloft.net>
References: <CAK6E8=fWOe3eEvw6sC=Da415qGp+wXsm2bpe9Vbbukit9yU8sQ@mail.gmail.com>
	<520BE51F.40208@hp.com>
	<1376515097.9293.6.camel@nexus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, ycheng@google.com, netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754319Ab3HOATR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 20:19:17 -0400
In-Reply-To: <1376515097.9293.6.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Wed, 14 Aug 2013 23:18:17 +0200

> Nevertheless, shouldn't the stack keep on reading the input
> even if the local application is not interested in it?

Absolutely, positively, not.

It is a loss of data, and therefore TCP responds with a reset when
pending read data is not consumed by the application.
