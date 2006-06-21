From: David Miller <davem@davemloft.net>
Subject: Re: DF, IP ID always 0 and the reassembly protections
Date: Tue, 20 Jun 2006 17:19:12 -0700 (PDT)
Message-ID: <20060620.171912.70221261.davem@davemloft.net>
References: <44988877.2030205@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63704
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751399AbWFUATD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 20:19:03 -0400
To: rick.jones2@hp.com
In-Reply-To: <44988877.2030205@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 20 Jun 2006 16:44:55 -0700

> Doesn't that mechanism rely on watching the IP ID's between the pair of 
> IPs?  For both fragmented and non-fragmented datagrams? If so, does 
> always setting the IP ID to zero when DF is set affect that mechanism?

Only the IDs in packets with DF clear matter.
