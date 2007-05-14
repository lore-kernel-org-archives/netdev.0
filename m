From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: compile breakage due to [SK_BUFF]: Convert skb->end to sk_buff_data_t
Date: Mon, 14 May 2007 08:42:04 +0300
Message-ID: <20070514054204.GD4343@rhun.haifa.ibm.com>
References: <200704271703.l3RH3i2F021726@hera.kernel.org> <20070513182941.GC4343@rhun.haifa.ibm.com> <46479EE7.1030100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:53466 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757737AbXENFmR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 01:42:17 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id l4E5gGIa259002
	for <netdev@vger.kernel.org>; Mon, 14 May 2007 05:42:16 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4E5gFQv4047006
	for <netdev@vger.kernel.org>; Mon, 14 May 2007 07:42:16 +0200
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4E5g5co023835
	for <netdev@vger.kernel.org>; Mon, 14 May 2007 07:42:05 +0200
Content-Disposition: inline
In-Reply-To: <46479EE7.1030100@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, May 13, 2007 at 08:27:35PM -0300, Arnaldo Carvalho de Melo wrote:

> Well, the fix is easy, can you provide a patch?

Sure, but I was hoping you had a follow-on patch to get rid of the
ugly ifdefs in .c files that would make it irrelevant? if not I'll
whip out the obvious patch.

Cheers,
Muli
