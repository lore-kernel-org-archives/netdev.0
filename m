From: David Miller <davem@davemloft.net>
Subject: Re: udp: Fix bogus UFO packet generation
Date: Mon, 21 Jun 2010 13:57:50 -0700 (PDT)
Message-ID: <20100621.135750.246543129.davem@davemloft.net>
References: <20100615115225.GA7239@gondor.apana.org.au>
	<20100615121530.GC2361@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757955Ab0FUU5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:57:38 -0400
In-Reply-To: <20100615121530.GC2361@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 15 Jun 2010 15:15:30 +0300

> On Tue, Jun 15, 2010 at 09:52:25PM +1000, Herbert Xu wrote:
>> Hi:
>> 
>> udp: Fix bogus UFO packet generation
>> 
>> It has been reported that the new UFO software fallback path
>> fails under certain conditions with NFS.  I tracked the problem
>> down to the generation of UFO packets that are smaller than the
>> MTU.  The software fallback path simply discards these packets.
>> 
>> This patch fixes the problem by not generating such packets on
>> the UFO path.
>> 
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> FWIW
> Reviewed-by: Michael S. Tsirkin <mst@redhat.com>

Applied, thanks everyone.
