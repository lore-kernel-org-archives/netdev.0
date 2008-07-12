From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: REDIRECT in nat OUTPUT
Date: Sat, 12 Jul 2008 17:40:25 +0300
Message-ID: <200807121740.25789.denys@visp.net.lb>
References: <200807120424.56462.denys@visp.net.lb> <20080712062812.GA7609@2ka.mipt.ru> <200807121655.44547.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200807121655.44547.denys@visp.net.lb>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seems i found something. After issuing ethtool -K lo tso on i got significant performance improvement.
Why it is not on by default?
Without it performance is VERY poor.

On Saturday 12 July 2008, Denys Fedoryshchenko wrote:
> There is nothing unusual on oprofile. And seems it is not CPU bottleneck, while i am doing tests it is not loaded 100% (i am using mpstat 1 -P ALL to measure that).
> But i will show first significant lines, if you want i can give full oprofile output, but i dont think it's matter.

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon
