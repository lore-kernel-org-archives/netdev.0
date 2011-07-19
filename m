From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 00/45] Update bna driver version to 3.0.2.0
Date: Mon, 18 Jul 2011 17:48:03 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A83BDF4A00@HQ1-EXCH01.corp.brocade.com>
References: <1310977178-312-1-git-send-email-rmody@brocade.com>
 <20110718.012639.1253140864720328605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:52449 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750868Ab1GSAsP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2011 20:48:15 -0400
In-Reply-To: <20110718.012639.1253140864720328605.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, July 18, 2011 1:27 AM
>
>This is too many patche at once.
>
>You need to submit patches more often, and in significantly smaller
>sets at a time.

David,

This update to the BNA driver (release 3.0) is enabling new hardware with various virtualization and other capabilities e.g. new 1860 SRIOV capable Fabric Adapter (new ASIC), vNIC (PF based virtualization), architectural framework for SR-IOV, Multi-Tx priority queue support and iSCSI over DCB.

The driver had to go through significant changes to enable these capabilities thus resulting in large delta. 

We explored options to submit smaller incremental patches in last few months but quickly ran into following issues ...
   - The driver was not functional between patches because of large developmental changes 
   - There were iterative changes to many areas of code and that was resulting in many unnecessary patches.

We wanted to avoid submitting developing code that could break upstream driver due to partial changes. 
Hence we ended up submitting this driver update patch with consolidated changes after elaborate QA testing.

We understand that it is still big and can think of following options to address the concern:
1. Break this submission into 3 batches and split it into: 2.3 fixes, new features (which is still a big patch set - due to all the code reorganization), and bug fixes and cleanup.
OR
2. Submit patches as a new driver and would need your support in replacing the existing upstream BNA driver with this one.

Please suggest on the next steps.

Thanks,
Rasesh
