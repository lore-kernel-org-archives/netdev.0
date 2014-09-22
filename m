From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] scsi: fix kconfig dependency warnings for SCSI_FC_ATTRS
Date: Mon, 22 Sep 2014 11:49:13 -0400 (EDT)
Message-ID: <20140922.114913.1747319060949253295.davem@davemloft.net>
References: <541CC163.3080709@infradead.org>
	<20140922144213.GA28200@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@infradead.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, jbottomley@parallels.com,
	anish@chelsio.com
To: hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51704 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbaIVPtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 11:49:19 -0400
In-Reply-To: <20140922144213.GA28200@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 22 Sep 2014 07:42:13 -0700

> On Fri, Sep 19, 2014 at 04:50:59PM -0700, Randy Dunlap wrote:
>> --- linux-next-20140918.orig/drivers/scsi/qla2xxx/Kconfig
>> +++ linux-next-20140918/drivers/scsi/qla2xxx/Kconfig
>> @@ -30,7 +30,7 @@ config SCSI_QLA_FC
>>  
>>  config TCM_QLA2XXX
>>  	tristate "TCM_QLA2XXX fabric module for Qlogic 2xxx series target mode HBAs"
>> -	depends on SCSI_QLA_FC && TARGET_CORE
>> +	depends on SCSI_QLA_FC && TARGET_CORE && SCSI_FC_ATTRS
> 
> CONFIG_SCSI_QLA_FC currently selects SCSI_FC_ATTRS, so we shouldn't
> need this here. Also any reason not to switch that one over to a
> depends as well?
> 

Yes, all selects of SCSI_FC_ATTRS have to be changed to a depends.
