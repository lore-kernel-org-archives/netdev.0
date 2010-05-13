From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 10/12] e1000e: move settting of flow
 control refresh timer to link setup code
Date: Wed, 12 May 2010 23:32:33 -0700 (PDT)
Message-ID: <20100512.233233.28819648.davem@davemloft.net>
References: <20100511005801.30827.50808.stgit@localhost.localdomain>
	<20100511010210.30827.6899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45050
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754100Ab0EMGcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 02:32:25 -0400
In-Reply-To: <20100511010210.30827.6899.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 10 May 2010 18:02:12 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The flow control refresh timer value needs to be saved off so that it can
> be programmed into the approrpiate register when applicable but without a
> reset, e.g. when changing flow control parameters via ethtool.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
