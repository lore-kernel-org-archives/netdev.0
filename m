From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 15/15] igb: add flushes between RAR writes
 when setting mac address
Date: Tue, 06 Oct 2009 15:22:05 -0700 (PDT)
Message-ID: <20091006.152205.07215643.davem@davemloft.net>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
	<20091005163601.32487.87871.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47945
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933827AbZJFWWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 18:22:11 -0400
In-Reply-To: <20091005163601.32487.87871.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 05 Oct 2009 09:36:01 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> There are some switches that will do write combining when they see two
> sequential regions written. In order to avoid any possible write combining
> issues it is necessary to add a flush after writing each piece of a rar
> register.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
