From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Wed, 15 Oct 2008 08:27:26 +0000
Message-ID: <20081015082726.GA5140@ff.dom.local>
References: <20081014175649.GA2548@ami.dom.local> <48F5049D.1000306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:34898 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853AbYJOI1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 04:27:32 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1163539nfc.21
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2008 01:27:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F5049D.1000306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 10:44:13PM +0200, Patrick McHardy wrote:
...
> I think we really need a peek operation since most qdiscs do have
> some internal priorization. The question is whether all qdiscs need
> it; I tend to think no.

Looking at qdisc_peek_len() seems to confirm a peek would be useful.
But since this all started from the question if ->requeue() could be
killed or simplified, I wonder if adding this peek could really help
with this problem without too much reworking. It looks like at least
sch_netem would still need more.

But if it's rather about adding something new and useful I'm OK with
this. Anyway, I need some time to rethink this one and your previous
description.

Thanks,
Jarek P.
