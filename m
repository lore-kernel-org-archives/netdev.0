From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : move Qdisc_class_ops and Qdisc_ops in
 appropriate sections
Date: Wed, 14 Nov 2007 01:45:03 -0800 (PST)
Message-ID: <20071114.014503.157524536.davem@davemloft.net>
References: <473AA62C.7080402@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40182
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754236AbXKNJpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:45:04 -0500
In-Reply-To: <473AA62C.7080402@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 14 Nov 2007 08:39:24 +0100

> [PATCH] NET : move Qdisc_class_ops and Qdisc_ops in appropriate sections
> 
> Qdisc_class_ops are const, and Qdisc_ops are mostly read.
> 
> Using "const" and "__read_mostly" qualifiers helps to reduce false sharing.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.25, thanks Eric.

Keep up the good work.
