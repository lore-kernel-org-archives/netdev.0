From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] e1000e: fix use of
 pci_enable_pcie_error_reporting
Date: Sat, 15 Aug 2009 18:53:23 -0700 (PDT)
Message-ID: <20090815.185323.115330476.davem@davemloft.net>
References: <20090815003524.2335.3107.stgit@localhost.localdomain>
	<20090815003551.2335.26888.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, dfeng@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53700
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753361AbZHPBxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2009 21:53:12 -0400
In-Reply-To: <20090815003551.2335.26888.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 14 Aug 2009 17:35:52 -0700

> From: Xiaotian Feng <dfeng@redhat.com>
> 
> commit 111b9dc5 introduces pcie aer support for e1000e, but it is not
> reasonable to disable it in e1000_remove but enable it in e1000_resume.
> This patch enables aer support in e1000_probe.
> 
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
