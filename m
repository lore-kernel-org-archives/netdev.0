From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 13:36:56 -0800
Message-ID: <56902BF8.6080004@hpe.com>
References: <568E9BF9.2050001@solarflare.com>
 <568E9C9B.3090408@solarflare.com>
 <CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
 <568FD844.3020101@solarflare.com>
 <CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
 <CAEh+42iX4AxEektcKSSeJ+OKX5Paa+ZY5T9vXC5KYtiLvjqixg@mail.gmail.com>
 <CAKgT0UcbH-BVbGxOuKx2EeX_Z5SgV8fdhDRjgoSC2eQTDjxNmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:30333 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754560AbcAHVg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 16:36:59 -0500
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com [15.216.225.55])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 597F9A4D
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 21:36:59 +0000 (UTC)
In-Reply-To: <CAKgT0UcbH-BVbGxOuKx2EeX_Z5SgV8fdhDRjgoSC2eQTDjxNmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2016 01:22 PM, Alexander Duyck wrote:
>  and we don't require the remote end to validate the outer checksum.

Doesn't the UDP specification require validating a non-zero checksum on 
receipt?

rick jones
