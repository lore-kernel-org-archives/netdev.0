From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 07:31:21 -0700
Message-ID: <46890C39.2040101@linux.intel.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org> <4689062A.8080809@linux.intel.com> <46890AED.7070906@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:51839 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753763AbXGBOdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 10:33:10 -0400
In-Reply-To: <46890AED.7070906@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> I'm not sure whether gcc is confused about ABI alignment or such, on 
> various platforms, but every time I look at the asm generated it is 
> /not/ equivalent to open-coded feature flags and bitwise logic.  Often 
> it is demonstrably worse.
> 
(I can imagine this being different if you forcefully pack your 
structure to align with hw masks, but that is obviously not the case here)
