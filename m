From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Thu, 28 Oct 2010 08:24:37 -0700
Message-ID: <1288279477.11251.5.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:40128 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756307Ab0J1PYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 11:24:42 -0400
In-Reply-To: <20101028052021.GD5599@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-28 at 07:20 +0200, Michael S. Tsirkin wrote:
> My concern is this can delay signalling for unlimited time.
> Could you pls test this with guests that do not have
> 2b5bbe3b8bee8b38bdc27dd9c0270829b6eb7eeb
> b0c39dbdc204006ef3558a66716ff09797619778
> that is 2.6.31 and older?

I will test it out.

> This seems to be slighltly out of spec, even though
> for TX, signals are less important.
> Two ideas:
> 1. How about writing out used, just delaying the signal?
>    This way we don't have to queue separately.
> 2. How about flushing out queued stuff before we exit
>    the handle_tx loop? That would address most of
>    the spec issue. 

I will modify the patch to test out the performance for both 1 & 2
approaches.

Thanks
Shirley



