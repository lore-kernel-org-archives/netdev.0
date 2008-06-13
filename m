From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 10/19] [repost] powerpc: move get_longbusy_msecs out of
 ehca/ehea
Date: Fri, 13 Jun 2008 15:55:41 -0400
Message-ID: <4852D0BD.7010403@pobox.com>
References: <20080612221848.GR30916@linux.vnet.ibm.com> <4852BB43.9080305@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Jennings <rcj@linux.vnet.ibm.com>, paulus@samba.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Santiago Leon <santil@us.ibm.com>,
	Nathan Fontenot <nfont@austin.ibm.com>,
	David Darrington <ddarring@linux.vnet.ibm.com>
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52843 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258AbYFMT4G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 15:56:06 -0400
In-Reply-To: <4852BB43.9080305@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian King wrote:
> Jeff,
> 
> Regarding the patches Rob just posted here, we'd like to just take them
> through the powerpc tree with your sign off since they are part of a
> Power platform feature we are enabling.
> 
> Thanks,
> 
> Brian
> 
> Robert Jennings wrote:
>> From: Robert Jennings <rcj@linux.vnet.ibm.com>
>>
>> In support of Cooperative Memory Overcommitment (CMO) this moves
>> get_longbusy_msecs() out of the ehca and ehea drivers and into the 
>> architecture's hvcall header as plpar_get_longbusy_msecs.  Some firmware
>> calls made in pSeries platform iommu code will need to share this
>> functionality.
>>
>> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
>>
>> ---
>>
>> I missed copying netdev on this patch the first time.
>>
>>  drivers/infiniband/hw/ehca/hcp_if.c |   24 ++----------------------
>>  drivers/net/ehea/ehea_phyp.c        |    4 ++--
>>  drivers/net/ehea/ehea_phyp.h        |   20 --------------------
>>  include/asm-powerpc/hvcall.h        |   27 +++++++++++++++++++++++++++
>>  4 files changed, 31 insertions(+), 44 deletions(-)

ACK the quoted patch


