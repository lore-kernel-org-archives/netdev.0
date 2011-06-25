From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [PATCH v2] vmxnet3: Enable GRO support.
Date: Fri, 24 Jun 2011 18:43:25 -0700
Message-ID: <03E840D17E263A48A5766AD576E0423A0129262C4F@exch-mbx-111.vmware.com>
References: <1308961475-25055-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Jesse Gross <jesse@nicira.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:22456 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751998Ab1FYBn1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 21:43:27 -0400
In-Reply-To: <1308961475-25055-1-git-send-email-jesse@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thanks again.

> When receiving packets from another guest on the same hypervisor, it's
> generally possible to receive large packets because no segmentation is
> necessary and these packets are handled by LRO.  However, when doing
> routing or bridging we must disable LRO and lose this benefit.  In
> these cases GRO can still be used and it is very effective because the
> packets which are segmented in the hypervisor are received very close
> together and can easily be merged.
> 
> CC: Shreyas Bhatewara <sbhatewara@vmware.com>
> CC: Scott Goldman <scottjg@vmware.com>
> CC: VMware PV-Drivers <pv-drivers@vmware.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Scott J. Goldman <scottjg@vmware.com>
