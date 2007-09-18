From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Tue, 18 Sep 2007 19:31:44 +0200
Message-ID: <46F00B80.7050901@trash.net>
References: <46F0087A.3080104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42542 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755766AbXIRRiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 13:38:24 -0400
In-Reply-To: <46F0087A.3080104@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert wrote:
> Limit of 1 is forbidden, crashes with 2, works with 3:
> 
>>From disassembling sch_sfq.ko it seems that it is on line 360 of sch_sfq.c:
>     sch->qstats.backlog -= skb->len;
> where "skb" is an invalid pointer:


Is it a NULL pointer or something random?
