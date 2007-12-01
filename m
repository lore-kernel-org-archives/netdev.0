From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-2.6.25 2/3][IPV4] Unify and cleanup calls to devinet_sysctl_register
Date: Sat, 01 Dec 2007 16:25:21 +0300
Message-ID: <475160C1.9050808@openvz.org>
References: <475055F2.4090509@openvz.org> <20071201132000.GG15910@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:49941 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752593AbXLANZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Dec 2007 08:25:31 -0500
In-Reply-To: <20071201132000.GG15910@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Fri, Nov 30, 2007 at 09:26:58PM +0300, Pavel Emelyanov wrote:
>> Besides, the inet_device is passed to this function, but
>> it is not needed there at all - just the device name and
>> ifindex are required.
> 
> But it is called devinet_* so an in_dev kind of makes sense :)
> 
>>  #ifdef CONFIG_SYSCTL
>> -	devinet_sysctl_register(in_dev, &in_dev->cnf);
>> +	devinet_sysctl_register(dev, &in_dev->cnf);
> 
> How about just giving it in_dev instead?

Hmm... Makes sense. Should I recreate the while set or
just make the incremental one?

> Thanks,

Thanks,
Pavel
