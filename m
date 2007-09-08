From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH v3 2/2][BNX2]: Add iSCSI support to BNX2 devices.
Date: Sat, 08 Sep 2007 07:32:27 -0400
Message-ID: <46E2884B.2070107@garzik.org>
References: <1188599815.5176.12.camel@dell>	<46E1D27F.2040701@cs.wisc.edu> <20070908084127G.tomof@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: open-iscsi@googlegroups.com, davem@davemloft.net,
	mchristi@redhat.com, netdev@vger.kernel.org, anilgv@broadcom.com,
	talm@broadcom.com, lusinsky@broadcom.com, uri@broadcom.com,
	fujita.tomonori@lab.ntt.co.jp
To: FUJITA Tomonori <tomof@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37596 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbXIHLch (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2007 07:32:37 -0400
In-Reply-To: <20070908084127G.tomof@acm.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FUJITA Tomonori wrote:
> Yeah, iommu code ignores the lld limitations (the problem is that the
> lld limitations are in request_queue and iommu code can't access to
> request_queue). There is no way to tell iommu code about the lld
> limitations.


This fact very much wants fixing.

	Jeff


