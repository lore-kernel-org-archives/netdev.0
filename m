From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [PATCH v12 06/17] Use callback to deal with skb_release_data()
 specially.
Date: Tue, 12 Oct 2010 09:24:48 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D793064B2AC43@shsmsx502.ccr.corp.intel.com>
References: <f2bf65a8a7676bbd3e8a749ae93d99e88671d35d.1285853725.git.xiaohui.xin@intel.com>
	 <20101001.001439.85411154.davem@davemloft.net>
	 <F2E9EB7348B8264F86B6AB8151CE2D793064B2A9D8@shsmsx502.ccr.corp.intel.com>
	 <20101011.082728.193709462.davem@davemloft.net>
 <1286811731.2737.28.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286811731.2737.28.camel@edumazet-laptop>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>Sent: Monday, October 11, 2010 11:42 PM
>To: David Miller
>Cc: Xin, Xiaohui; netdev@vger.kernel.org; kvm@vger.kernel.org;
>linux-kernel@vger.kernel.org; mst@redhat.com; mingo@elte.hu;
>herbert@gondor.apana.org.au; jdike@linux.intel.com
>Subject: Re: [PATCH v12 06/17] Use callback to deal with skb_release_d=
ata() specially.
>
>Le lundi 11 octobre 2010 =E0 08:27 -0700, David Miller a =E9crit :
>> From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
>> Date: Mon, 11 Oct 2010 15:06:05 +0800
>>
>> > That's to avoid the new cache miss caused by using destructor_arg =
in data path
>> > like skb_release_data().
>> > That's based on the comment from Eric Dumazet on v7 patches.
>>
>> Thanks for the explanation.
>
>Anyway, frags[] must be the last field of "struct skb_shared_info"
>since commit fed66381 (net: pskb_expand_head() optimization)
>
>It seems Xin worked on a quite old tree.
>
>
I will rebase soon.

Thanks
Xiaohui
