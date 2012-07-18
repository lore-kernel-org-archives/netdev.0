From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Wed, 18 Jul 2012 17:59:10 +0300
Message-ID: <5006CF3E.8090903@mellanox.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com> <50044F1D.6000703@hp.com> <20120716190611.GA1023@oc1711230544.ibm.com> <50046EB1.5040909@hp.com> <CAJZOPZL3F+xdHSFfhg7v9A6DDjT6CPK=kgwyzcE6c0pGYFyupg@mail.gmail.com> <20120716205708.GB16137@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz@gmail.com>, Rick Jones <rick.jones2@hp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"anton@samba.org" <anton@samba.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:52150 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752430Ab2GRO75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 10:59:57 -0400
In-Reply-To: <20120716205708.GB16137@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/16/2012 11:57 PM, Thadeu Lima de Souza Cascardo wrote:
> On Mon, Jul 16, 2012 at 11:43:33PM +0300, Or Gerlitz wrote:
>>
>>
>> TCP_STREAM from this setup before the patch would be good to know as well
>>
>
> Does the stream test that I did with uperf using messages of 64000 bytes fit?

netperf/TCP_STREAM is very common and it would help to better compare 
the numbers
you get on your systems before/after the patch which runs done here. As 
for review for
the patch itself and the related discussion, Yevgeny Petrilin should be 
looking on your
patch, he'll be in by early next week.

Or.
