From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] mlx4_en: map entire pages to increase throughput
Date: Mon, 16 Jul 2012 12:42:41 -0700
Message-ID: <50046EB1.5040909@hp.com>
References: <1342458113-10384-1-git-send-email-cascardo@linux.vnet.ibm.com> <50044F1D.6000703@hp.com> <20120716190611.GA1023@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yevgenyp@mellanox.co.il" <yevgenyp@mellanox.co.il>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"brking@linux.vnet.ibm.com" <brking@linux.vnet.ibm.com>,
	"leitao@linux.vnet.ibm.com" <leitao@linux.vnet.ibm.com>,
	"klebers@linux.vnet.ibm.com" <klebers@linux.vnet.ibm.com>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"anton@samba.org" <anton@samba.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:25258 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963Ab2GPTmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 15:42:52 -0400
In-Reply-To: <20120716190611.GA1023@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/16/2012 12:06 PM, Thadeu Lima de Souza Cascardo wrote:
> On Mon, Jul 16, 2012 at 10:27:57AM -0700, Rick Jones wrote:
>
>> What is the effect on packet-per-second performance?  (eg aggregate,
>> burst-mode netperf TCP_RR with TCP_NODELAY set or perhaps UDP_RR)
>>
> I used uperf with TCP_NODELAY and 16 threads sending from another
> machine 64000-sized writes for 60 seconds.
>
> I get 5898op/s (3.02Gb/s) without the patch against 18022ops/s
> (9.23Gb/s) with the patch.

I was thinking more along the lines of an additional comparison, 
explicitly using netperf TCP_RR or something like it, not just the 
packets per second from a bulk transfer test.

rick
