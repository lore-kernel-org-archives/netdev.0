From: Lawrence Brakmo <brakmo@fb.com>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Mon, 6 Jul 2015 22:40:17 +0000
Message-ID: <D1C050BB.47A5%brakmo@fb.com>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
 <20150703.094704.283183007204034386.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:15243 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753687AbbGFWl4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2015 18:41:56 -0400
In-Reply-To: <20150703.094704.283183007204034386.davem@davemloft.net>
Content-Language: en-US
Content-ID: <F34729A537C7C846B2229358E927BB5A@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 7/3/15, 9:47 AM, "David Miller" <davem@davemloft.net> wrote:

>From: Lawrence Brakmo <brakmo@fb.com>
>Date: Thu, 2 Jul 2015 18:21:24 -0700
>
>> This is a request for comments.
>>=20
>> TCP-NV (New Vegas) is a major update to TCP-Vegas. An earlier versio=
n of
>> NV was presented at 2010's LPC (slides). It is a delayed based
>> congestion avoidance for the data center. This version has been test=
ed
>> within a 10G rack where the HW RTTs are 20-50us.
>>=20
>> A description of TCP-NV, including implementation and experimental
>> results, can be found at:
>> http://www.brakmo.org/networking/tcp-nv/TCPNV.html
>>=20
>> The current version includes many module parameters to support
>> experimentation with the parameters.
>>=20
>> Signed-off-by: Lawrence Brakmo <lawrence@brakmo.org>
>
>I'm disappointed in the skb->cb[] size increase, like Eric.  This
>severely negatively impacts everyone on every Linux system in the
>world, not just people using NV.
>
>The performance implications from increasing sk_buff by even 1 byte in
>size are absolutely non-trivial.

I will look into Neal=B9s comment regarding using a union in the skb->c=
b[]
so I don=B9t have to increase skb->cb[] size.
