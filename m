From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 2/6] igb: make rxcsum configuration seperate
 from multiqueue
Date: Tue, 28 Apr 2009 01:54:29 -0700 (PDT)
Message-ID: <20090428.015429.244997124.davem@davemloft.net>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
	<20090428083513.32417.95815.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755433AbZD1Iyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:54:36 -0400
In-Reply-To: <20090428083513.32417.95815.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 28 Apr 2009 01:35:14 -0700

> The igb driver was being incorrectly setup to only allow disabling receive
> checksum if multiqueue was disabled.  This change corrects that so that
> RXCSUM is configured regardless of queue configuration.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
