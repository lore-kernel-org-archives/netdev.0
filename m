From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 09:48:34 +0200
Message-ID: <48118CD2.6000706@firstfloor.org>
References: <d1c2719f0804241829s1bc3f41ejf7ebbff73ed96578@mail.gmail.com>	<48118308.1090407@firstfloor.org> <20080425.002804.152322163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, johnwheffner@gmail.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53108 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760107AbYDYHsi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:48:38 -0400
In-Reply-To: <20080425.002804.152322163.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Andi Kleen <andi@firstfloor.org>
> Date: Fri, 25 Apr 2008 09:06:48 +0200
> 
>> The only big problem then would be if there are more submitting threads
>> than packets in the TX queue, but I would consider that unlikely for
>> GB+ NICs at least (might be an issue for older designs with smaller queues)
> 
> It's probably exactly what happens in those chat server benchmarks.

In that case we might be better off just blocking some of these threads
until the TX queue cleared? What good is it to send faster than the
network allows?

-Andi


