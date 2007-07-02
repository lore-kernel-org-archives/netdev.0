From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 07:05:30 -0700
Message-ID: <4689062A.8080809@linux.intel.com>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	akpm@linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:51717 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752856AbXGBOHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 10:07:21 -0400
In-Reply-To: <4688F512.3030801@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 >> +    u32 alloc_rx_buff_failed;
>> +    struct {
>> +        unsigned int rx_csum_enabled    :1;
>> +        unsigned int msi_capable    :1;
>> +        unsigned int msi_enabled    :1;
>> +        unsigned int msix_capable    :1;
>> +        unsigned int msix_enabled    :1;
>> +        unsigned int imir_enabled    :1;
>> +        unsigned int in_netpoll        :1;
>> +    } flags;
> 
> always avoid bitfields.  They generate horrible code, and endian 
> problems abound (though no endian problems are apparent here).

they generate no worse code than open coding the checks for these 
feature flags...
