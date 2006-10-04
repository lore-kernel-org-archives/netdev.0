From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] network namespaces
Date: Wed, 04 Oct 2006 11:40:32 +0200
Message-ID: <45238190.7090709@fr.ibm.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, herbert@13thfloor.at, sam@vilain.net,
	ebiederm@xmission.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:36706 "EHLO
	mtagate6.de.ibm.com") by vger.kernel.org with ESMTP
	id S1161129AbWJDJkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 05:40:32 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id k949eUlB148250
	for <netdev@vger.kernel.org>; Wed, 4 Oct 2006 09:40:30 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k949gdGX3236052
	for <netdev@vger.kernel.org>; Wed, 4 Oct 2006 11:42:39 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k949eToi025374
	for <netdev@vger.kernel.org>; Wed, 4 Oct 2006 11:40:30 +0200
To: Andrey Savochkin <saw@sw.ru>
In-Reply-To: <20060815182029.A1685@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrey Savochkin wrote:
> Hi All,
> 
> I'd like to resurrect our discussion about network namespaces.
> In our previous discussions it appeared that we have rather polar concepts
> which seemed hard to reconcile.
> Now I have an idea how to look at all discussed concepts to enable everyone's
> usage scenario.

Hi Andrey,

I have a few questions ... sorry for asking so late ;)

> 
> 1. The most straightforward concept is complete separation of namespaces,
>    covering device list, routing tables, netfilter tables, socket hashes, and
>    everything else.
> 
>    On input path, each packet is tagged with namespace right from the
>    place where it appears from a device, and is processed by each layer
>    in the context of this namespace.

If you have the namespace where is coming the packet, why do you tag the 
packet instead of switching to the right namespace ?

>    Non-root namespaces communicate with the outside world in two ways: by
>    owning hardware devices, or receiving packets forwarded them by their parent
>    namespace via pass-through device.

Do you will do proxy arp and ip forwarding into the root namespace in 
order to make non-root namespace visible from the outside world ?

Regards.

	-- Daniel
