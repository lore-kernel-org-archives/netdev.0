From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] myri10ge: fix rmmod crash
Date: Wed, 23 Mar 2011 12:31:56 -0700 (PDT)
Message-ID: <20110323.123156.15222378.davem@davemloft.net>
References: <20110323124412.GA7813@redhat.com>
	<4D89F111.7030506@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, netdev@vger.kernel.org, brice@myri.com,
	stable@kernel.org
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60386
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932628Ab1CWTbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:31:17 -0400
In-Reply-To: <4D89F111.7030506@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 23 Mar 2011 09:09:37 -0400

> On 03/23/11 08:44, Stanislaw Gruszka wrote:
>> Rmmod myri10ge crash at free_netdev() -> netif_napi_del(), because
>> napi
>> structures are already deallocated. To fix call netif_napi_del()
>> before
>> kfree() at myri10ge_free_slices().
> 
> I apologize; I made a similar fix myself to our tree last fall simply
> forgot to post it to netdev... I'm terribly sorry for the time
> you wasted chasing this.   At any rate...
> 
> Acked by: Andrew Gallatin <gallatin@myri.com>

Patch applied, thanks everyone.
