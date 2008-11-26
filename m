From: Michal Soltys <soltys@ziu.info>
Subject: Re: Question about HFSC atm+man patches
Date: Wed, 26 Nov 2008 23:54:17 +0100
Message-ID: <492DD399.4040801@ziu.info>
References: <49292F54.4020803@ziu.info> <4929632F.3050200@trash.net> <492AB29A.3010601@ziu.info> <492AB60A.9050606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:2701 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068AbYKZWyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2008 17:54:16 -0500
In-Reply-To: <492AB60A.9050606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One question regarding size tables:

Should I assume that subsequent qdiscs attached to HFSC leaves will not 
use [different] size tables ?

This is currently the case, but from the perspective of a generic 
solution - if some inner qdisc changes pkt_len stored in cb area during 
qdisc_enqueue, then HFSC might get wrong size during peek operation.

As leaves will usually have "simple" work-conserving qdiscs attached, 
this is probably not an issue, but ...

