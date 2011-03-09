From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: Network performance with small packets
Date: Wed, 09 Mar 2011 07:42:03 -0800
Message-ID: <1299685323.25664.94.camel@localhost.localdomain>
References: <20110127.130240.104065182.davem@davemloft.net>
	 <OF5CFD7B6A.4CBE4E3B-ON6525782B.0014DC5B-6525782B.001979CB@in.ibm.com>
	 <20110202044222.GC3818@redhat.com>
	 <201102091107.20270.rusty@rustcorp.com.au>
	 <1299621444.25664.77.camel@localhost.localdomain>
	 <1299637278.13202.61.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, steved@us.ibm.com,
	Tom Lendacky <tahm@linux.vnet.ibm.com>
To: habanero@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:47851 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753277Ab1CIPmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 10:42:16 -0500
In-Reply-To: <1299637278.13202.61.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-08 at 20:21 -0600, Andrew Theurer wrote:
> Tom L has started using Rusty's patches and found some interesting
> results, sent yesterday:
> http://marc.info/?l=kvm&m=129953710930124&w=2

Thanks. Very good experimental. I have been struggling with guest/vhost
optimization work for a while. I created different experimental patches,
performance results really depends on workloads.

Based on the discussions and findings, seems that to improve
virtio_net/vhost optimization work, we really need to collect more
statistics data on both virtio_net and vhost for both TX and RX. 

A way to filter number of guest exits, I/O exits, irq injections in
guest networking stacks only would be helpful.

Thanks
Shirley

