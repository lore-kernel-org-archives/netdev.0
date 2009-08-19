From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: mlx4 2.6.31-rc5: SW2HW_EQ failed.
Date: Wed, 19 Aug 2009 12:29:50 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908191229280.32015@gentwo.org>
References: <alpine.DEB.1.10.0908171523330.20399@gentwo.org> <ada7hx22j3g.fsf@cisco.com> <alpine.DEB.1.10.0908171814210.15956@gentwo.org> <ada3a7p3o6f.fsf@cisco.com> <adaljlg1e0x.fsf@cisco.com> <alpine.DEB.1.10.0908190743410.5621@gentwo.org>
 <adaeir7256h.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.ultrahosting.com ([74.213.175.254]:44356 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753193AbZHSQ3z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 12:29:55 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 7911F82C605
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 12:30:13 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 2E8wjZW2rrd9 for <netdev@vger.kernel.org>;
	Wed, 19 Aug 2009 12:30:08 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5BEBA82C5D7
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 12:30:07 -0400 (EDT)
In-Reply-To: <adaeir7256h.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Aug 2009, Roland Dreier wrote:

>  > We ran an old 2.6.26 debian kernel on this and it worked fine.
>
> The change to mlx4 to use multiple completion interrupts went in around
> 2.6.29 I think.  So that sort of explains why things would work with 2.6.26.

I also see a 2 usecs latency increase with 2.6.31 vs 2.6.30.

