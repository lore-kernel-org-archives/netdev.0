From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH 00/45] Update bna driver version to 3.0.2.0
Date: Tue, 19 Jul 2011 15:53:06 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A83BDF4C07@HQ1-EXCH01.corp.brocade.com>
References: <1310977178-312-1-git-send-email-rmody@brocade.com>
	<20110718.012639.1253140864720328605.davem@davemloft.net>
	<E5313AF6F2BFD14293E5FD0F94750F86A83BDF4A00@HQ1-EXCH01.corp.brocade.com>
 <20110718.185805.413849001475627611.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Adapter Linux Open SRC Team"
	<adapter_linux_open_src_team@Brocade.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37050 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751740Ab1GSWxU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2011 18:53:20 -0400
In-Reply-To: <20110718.185805.413849001475627611.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: David Miller [mailto:davem@davemloft.net]
>Sent: Monday, July 18, 2011 6:58 PM
>
>From: Rasesh Mody <rmody@brocade.com>
>Date: Mon, 18 Jul 2011 17:48:03 -0700
>
>> We wanted to avoid submitting developing code that could break
>> upstream driver due to partial changes.
>
>So what you're saying is that if only some of the patches are applied
>the driver will not work properly?
>
>That's not allowed either, your set of changes must be fully
>bisectable meaning that at any point in the series the driver
>must still compile and work properly.
>
>You guys need to sort out how you guys submit your changes.
>
>When you have 4 patches ready to go, post them immediately.
>
>Because if there are fundamental problem with the first 4,
>everything else that depends upon them will need to change.

David,

We can further split the submission into multiple smaller submissions (e.g. 4 patches a time as you suggested), but there still will be one big patch set for new hardware and feature enablement, which cannot be split it into small bisectable patches. Is this acceptable? What is the upstream guideline for submitting big changes such as driver re-architecture or re-organization?

Thanks,
--Rasesh
