From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] scsi: use 'depends' instead of 'select' for
 SCSI_FC_ATTRS
Date: Tue, 16 Sep 2014 16:56:14 -0400 (EDT)
Message-ID: <20140916.165614.1047136442384470192.davem@davemloft.net>
References: <5418A1ED.3010302@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbottomley@parallels.com, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754892AbaIPU4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:56:15 -0400
In-Reply-To: <5418A1ED.3010302@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Tue, 16 Sep 2014 13:47:41 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> There are other kconfig symbols which use SCSI_FC_ATTRS.
> In order to maintain sanity and prevent kconfig warnings, change
> all of these from using 'select' to using 'depends on' so that
> proper symbol dependencies will be honored and circular depends
> problems will be avoided.
> This fixes kconfig warnings and build errors:
> 
> warning: (LIBFC && SCSI_IBMVFC && SCSI_QLA_FC && SCSI_LPFC && ZFCP && SCSI_BFA_FC && SCSI_CHELSIO_FCOE && FUSION_FC) selects SCSI_FC_ATTRS which has unmet direct dependencies (SCSI && NET)
> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_event':
> drivers/scsi/scsi_transport_fc.c:543:7: error: 'scsi_nl_sock' undeclared (first use in this function)
> drivers/scsi/scsi_transport_fc.c: In function 'fc_host_post_vendor_event':
> drivers/scsi/scsi_transport_fc.c:611:7: error: 'scsi_nl_sock' undeclared (first use in this function)
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
