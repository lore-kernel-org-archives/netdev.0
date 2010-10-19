From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/7] Move vlan acceleration into networking core.
Date: Tue, 19 Oct 2010 02:50:39 -0700 (PDT)
Message-ID: <20101019.025039.112595275.davem@davemloft.net>
References: <1287000177-7126-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752498Ab0JSJuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 05:50:16 -0400
In-Reply-To: <1287000177-7126-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Wed, 13 Oct 2010 13:02:50 -0700

> Hardware vlan acceleration behaves fairly differently from other
> types of offloading, which limits its usefulness.  This patch series
> aims to bring it more in line with other common forms of
> acceleration, such as checksum offloading and TSO.  In doing this it
> eliminates common driver bugs, increases flexibility, and improves
> performance, while reducing the number of lines of code.
> 
> The first four patches can be applied immediately, while the last
> three need to wait until all drivers that support vlan acceleration
> are updated.  If people agree that this patch set makes sense I will
> go ahead and switch over the dozen or so drivers that would need to
> change.

These changes look great (and everyone I've asked tends to agree)
so please submit the updated series with feedback integrated
and I'll add at least the first 4 patches to net-next-2.6

Thanks!
