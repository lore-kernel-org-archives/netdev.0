From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [0/5] GSO: Generic Segmentation Offload
Date: Tue, 20 Jun 2006 09:18:45 -0700
Message-ID: <44981FE5.5010004@hp.com>
References: <20060620090919.GA31613@gondor.apana.org.au> <20060620093219.GF31854@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:26274 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S1751390AbWFTQSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 12:18:48 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060620093219.GF31854@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> $ sudo ./ethtool -K lo gso on
> $ sudo ifconfig lo mtu 1500
> $ netperf -t TCP_STREAM
> TCP STREAM TEST to localhost
> Recv   Send    Send
> Socket Socket  Message  Elapsed
> Size   Size    Size     Time     Throughput
> bytes  bytes   bytes    secs.    10^6bits/sec
> 
>  87380  16384  16384    10.00    3598.17

Would it really mess people up if netperf started doing CPU utilization 
measurements by default on those platforms where it did not require 
prior calibrarion?  I think that might make it more likely that when 
folks run tests, even over loopback (esp on MP), we'll get the service 
demand figures that help show the the change in stack efficiency.

rick jones

BTW, the style of the netperf test banner tells me you might want to 
upgrade to a newer version of netperf :)
