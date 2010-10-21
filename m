From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/14] Move vlan acceleration into networking core.
Date: Thu, 21 Oct 2010 01:33:33 -0700 (PDT)
Message-ID: <20101021.013333.189715307.davem@davemloft.net>
References: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33451
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751307Ab0JUIdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 04:33:10 -0400
In-Reply-To: <1287618974-4714-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Wed, 20 Oct 2010 16:56:00 -0700

> Hardware vlan acceleration behaves fairly differently from other types of
> offloading, which limits its usefulness.  This patch series aims to bring
> it more in line with other common forms of acceleration, such as checksum
> offloading and TSO.  In doing this it eliminates common driver bugs, increases
> flexibility, and improves performance, while reducing the number of lines of
> code.
> 
> The first eleven patches can be applied immediately, while the last three need
> to wait until all drivers that support vlan acceleration are updated.  If
> people agree that this patch set makes sense I will go ahead and switch over
> the dozen or so drivers that would need to change.

First 11 patches applied, thanks!
