From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]NET/KS8695: add support NAPI for Rx
Date: Mon, 26 Oct 2009 15:43:09 -0700 (PDT)
Message-ID: <20091026.154309.165520821.davem@davemloft.net>
References: <1256572828.2148.5.camel@myhost>
	<1256575746.2783.37.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: figo1802@gmail.com, dsilvers@simtec.co.uk, netdev@vger.kernel.org,
	vince@simtec.co.uk, ben@simtec.co.uk
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754358AbZJZWmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 18:42:46 -0400
In-Reply-To: <1256575746.2783.37.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 26 Oct 2009 16:49:06 +0000

>> @@ -152,6 +156,10 @@ struct ks8695_priv {
>>  	enum ks8695_dtype dtype;
>>  	void __iomem *io_regs;
>>  
>> +	#ifdef KS8695NET_NAPI
>> +	struct napi_struct	napi;
>> +	#endif
>> +
> 
> NAPI is well-established and there should be no need to make it
> optional.  So far as I'm aware, all other drivers that had it as an
> option now use it unconditionally.

I absolutely refuse to apply this patch with the CPP conditional
present, if you convert to NAPI make it unconditional.
