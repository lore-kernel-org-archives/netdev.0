From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question about HFSC atm+man patches
Date: Thu, 27 Nov 2008 11:48:43 +0100
Message-ID: <492E7B0B.8000601@trash.net>
References: <49292F54.4020803@ziu.info> <4929632F.3050200@trash.net> <492AB29A.3010601@ziu.info> <492AB60A.9050606@trash.net> <492DD399.4040801@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47233 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756867AbYK0Ksy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 05:48:54 -0500
In-Reply-To: <492DD399.4040801@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michal Soltys wrote:
> One question regarding size tables:
> 
> Should I assume that subsequent qdiscs attached to HFSC leaves will not 
> use [different] size tables ?
> 
> This is currently the case, but from the perspective of a generic 
> solution - if some inner qdisc changes pkt_len stored in cb area during 
> qdisc_enqueue, then HFSC might get wrong size during peek operation.
> 
> As leaves will usually have "simple" work-conserving qdiscs attached, 
> this is probably not an issue, but ...

Using different size tables for inner qdiscs is supposed to work.
What is the "wrong size"? ->peek() should return a packet with the
size the same as ->dequeue() would, which I think it does.
