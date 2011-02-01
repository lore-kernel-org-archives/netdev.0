From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCHv2 dontapply] vhost-net tx tuning
Date: Tue, 01 Feb 2011 15:27:25 -0800
Message-ID: <1296602845.26937.834.camel@localhost.localdomain>
References: <OFD293DCD2.7F0260F0-ON86257823.0061DC39-86257823.00743BB3@us.ibm.com>
	 <20110126151700.GA14113@redhat.com>
	 <1296153874.1640.27.camel@localhost.localdomain>
	 <20110127190031.GC5228@redhat.com>
	 <1296155340.1640.34.camel@localhost.localdomain>
	 <20110127193131.GD5228@redhat.com>
	 <1296157547.1640.45.camel@localhost.localdomain>
	 <20110127200548.GE5228@redhat.com>
	 <1296159305.1640.50.camel@localhost.localdomain>
	 <OF381CCA86.B82857CC-ON86257826.00629F88-86257826.006596F5@us.ibm.com>
	 <20110201155253.GA22959@redhat.com>
	 <1296601658.30191.46.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	mashirle@linux.vnet.ibm.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:35944 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396Ab1BAX1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 18:27:30 -0500
In-Reply-To: <1296601658.30191.46.camel@sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-02-01 at 15:07 -0800, Sridhar Samudrala wrote:
> I think the counters that exceed the limits need to be reset to 0
> here.
> Otherwise we keep signaling for every buffer once we hit this
> condition. 

I will modify the patch to rerun the test to see the difference.

Shirley

