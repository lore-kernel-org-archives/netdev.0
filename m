From: Scott Goldman <scottjg@vmware.com>
Subject: RE: [Pv-drivers] [PATCH net-next] vmxnet3: set netdev parant device
 before calling netdev_info
Date: Wed, 20 Jul 2011 20:06:05 -0700
Message-ID: <03E840D17E263A48A5766AD576E0423A03C5836359@exch-mbx-111.vmware.com>
References: <alpine.LRH.2.00.1107201834220.19334@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:37194 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751822Ab1GUDHr convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 23:07:47 -0400
Received: from mailhost2.vmware.com (mailhost2.vmware.com [10.16.67.167])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 9C8102B0F9
	for <netdev@vger.kernel.org>; Wed, 20 Jul 2011 20:07:47 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.1107201834220.19334@sbhatewara-dev1.eng.vmware.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Parent device for netdev should be set before netdev_info() can be called
> otherwise there is a NULL pointer dereference and probe() fails.

> Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
Signed-off-by: Scott J. Goldman <scottjg@vmware.com>