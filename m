From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 14 Aug 2014 12:59:18 -0700
Message-ID: <53ED1516.6020801@hp.com>
References: <53ECFDAB.5010701@intel.com> <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:41348 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbaHNT7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 15:59:55 -0400
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com [15.217.128.51])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 3115A4C98
	for <netdev@vger.kernel.org>; Thu, 14 Aug 2014 19:59:55 +0000 (UTC)
In-Reply-To: <1408041962.6804.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/14/2014 11:46 AM, Eric Dumazet wrote:

> I believe you answered your own question : prequeue mode does not work
> very well when one host has hundred of active TCP flows to one other.
>
> In real life, applications do not use prequeue, because nobody wants one
> thread per flow.
>
> Each socket has its own dst now route cache was removed, but if your
> netperf migrates cpu (and NUMA node), we do not detect the dst should be
> re-created onto a different NUMA node.

Presumably, the -T $i,$j option in Alex's netperf command lines will 
have bound netperf and netserver to a specific CPU where they will have 
remained.

rick jones
