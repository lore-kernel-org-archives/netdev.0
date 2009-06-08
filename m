From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 3/4] iscsi class, libiscsi: Add net config.
Date: Mon, 08 Jun 2009 13:07:48 -0500
Message-ID: <4A2D5374.3030503@cs.wisc.edu>
References: <1241208039-6813-1-git-send-email-mchan@broadcom.com>	 <1241208039-6813-4-git-send-email-mchan@broadcom.com> <1244483774.4079.368.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:41209 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbZFHSH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 14:07:57 -0400
In-Reply-To: <1244483774.4079.368.camel@mulgrave.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Bottomley wrote:
> On Fri, 2009-05-01 at 13:00 -0700, Michael Chan wrote:
>> Add ISCSI_NETLINK messages to get/set vendor specific information.
>> This is to support bnx2i that handles net config of private iSCSI
>> IP address in userspace.
>>
>> Signed-off-by: Anil Veerabhadrappa <anilgv@broadcom.com>
>> Signed-off-by: Michael Chan <mchan@broadcom.com>
>> Signed-off-by: Mike Christie <michaelc@cs.wisc.edu>
>> Acked-by: David S. Miller <davem@davemloft.net>
> 
> This patch is rejecting pretty badly against both SCSI and net ... is
> there an update (I saw you updated the other three patches in this
> series on the 23rd, but not this one)?
> 

The patch in this mail was dropped in their newest patchset from the 23rd.

Instead of the patch in this mail we now added the patch "[PATCH 1/4] 
iscsi class: Add new NETLINK_ISCSI messages for cnic/bnx2i driver." 
(link http://marc.info/?l=linux-scsi&m=124311620603619&w=2)  that was 
posted with the updated bnx2i/cnic patches on the 23rd.

James, one note. I was reviewing the bnx2i patch again and found some 
bugs in the locking. Are you going to merge the patches that were sent 
on the 23rd and then do you want us to just send fixes against that? Or 
do you want a new fixed up patchset?


