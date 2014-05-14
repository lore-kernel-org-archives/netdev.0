From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH net RFC] xen-netback: Fix grant ref resolution in RX path
Date: Wed, 14 May 2014 14:37:22 +0100
Message-ID: <53737192.9050104@citrix.com>
References: <1399991500-4432-1-git-send-email-zoltan.kiss@citrix.com>	 <1399997635.7973.56.camel@edumazet-glaptop2.roam.corp.google.com> <1400056335.21829.2.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	<xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<linux@eikelenboom.it>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>, <davem@davemloft.net>
To: Ian Campbell <Ian.Campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:17385 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751992AbaENNhZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 09:37:25 -0400
In-Reply-To: <1400056335.21829.2.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/05/14 09:32, Ian Campbell wrote:
>> I am not saying your patch is wrong, only that it adds yet an obscure
>> thing with no comments. In two years, nobody will understand this.
> 
> Agreed.

The long term solution is to make grant copy use the supplied VA to copy
to/from which would mean we no longer need to pass the grant ref around
to do the copy.

This is non-trivial and would required an updated Xen.

It would also fix other use cases (such as a domU providing an iSCSI
target which is used as the block device for a local blkback).

David
