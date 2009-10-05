From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/7] mlx4: Added interrupts test support
Date: Mon, 05 Oct 2009 09:18:23 -0700
Message-ID: <adar5tholv4.fsf@cisco.com>
References: <4AC4BD9A.2050101@mellanox.co.il> <adaeipmqxmv.fsf@cisco.com>
	<4AC9D59F.1090409@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:40279 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbZJEQTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:19:07 -0400
In-Reply-To: <4AC9D59F.1090409@mellanox.co.il> (Yevgeny Petrilin's message of
	"Mon, 05 Oct 2009 13:16:47 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > > Have you actually seen cases where
 > > the interrupt test during initialization works but then this test
 > > catches a problem?  (My experience has been that if any MSI-X interrupts
 > > work from a device, then they'll all work)

 > It also checks that all the EQs work properly. During initialization
 > we only check the asynchronous EQ

Yes, I understand what the code does.  My question was whether you have
ever actually observed a case where the async EQ works but another EQ
doesn't?  In other words is this test useful in practice?

 - R.
