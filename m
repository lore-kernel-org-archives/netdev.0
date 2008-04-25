From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 00:28:04 -0700 (PDT)
Message-ID: <20080425.002804.152322163.davem@davemloft.net>
References: <d1c2719f0804241829s1bc3f41ejf7ebbff73ed96578@mail.gmail.com>
	<48118308.1090407@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, johnwheffner@gmail.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755935AbYDYH2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:28:05 -0400
In-Reply-To: <48118308.1090407@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 25 Apr 2008 09:06:48 +0200

> The only big problem then would be if there are more submitting threads
> than packets in the TX queue, but I would consider that unlikely for
> GB+ NICs at least (might be an issue for older designs with smaller queues)

It's probably exactly what happens in those chat server benchmarks.

