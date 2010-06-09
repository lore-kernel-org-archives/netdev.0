From: "Xin, Xiaohui" <xiaohui.xin@intel.com>
Subject: RE: [RFC PATCH v7 08/19] Make __alloc_skb() to get external buffer.
Date: Wed, 9 Jun 2010 15:34:16 +0800
Message-ID: <F2E9EB7348B8264F86B6AB8151CE2D791100848EA7@shsmsx502.ccr.corp.intel.com>
References: <1275732899-5423-1-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-2-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-3-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-4-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-5-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-6-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-7-git-send-email-xiaohui.xin@intel.com>
	 <1275732899-5423-8-git-send-email-xiaohui.xin@intel.com>
 <1275749604.5238.239.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mst@redhat.com" <mst@redhat.com>, "mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22234 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab0FIHgb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 03:36:31 -0400
In-Reply-To: <1275749604.5238.239.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>Sent: Saturday, June 05, 2010 10:53 PM
>To: Xin, Xiaohui
>Cc: netdev@vger.kernel.org; kvm@vger.kernel.org; linux-kernel@vger.ker=
nel.org;
>mst@redhat.com; mingo@elte.hu; davem@davemloft.net; herbert@gondor.apa=
na.org.au;
>jdike@linux.intel.com
>Subject: Re: [RFC PATCH v7 08/19] Make __alloc_skb() to get external b=
uffer.
>
>Le samedi 05 juin 2010 =E0 18:14 +0800, xiaohui.xin@intel.com a =E9cri=
t :
>> From: Xin Xiaohui <xiaohui.xin@intel.com>
>> 	child->fclone =3D SKB_FCLONE_UNAVAILABLE;
>>  	}
>> +	/* Record the external buffer info in this field. It's not so good=
,
>> +	 * but we cannot find another place easily.
>> +	 */
>> +	shinfo->destructor_arg =3D ext_page;
>> +
>
>
>Yes this is a big problem, its basically using a cache line that was n=
ot
>touched before.
>

Did your patch which moves destructor_arg before frags[] also fix this?

Thanks
Xiaohui
