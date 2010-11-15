From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: guard the size of the nf_ct_ext
Date: Mon, 15 Nov 2010 19:35:33 +0800
Message-ID: <AANLkTi=pJG=Z8R2qLUm6m8wnCyZiKaZzmTxLZm08Jitj@mail.gmail.com>
References: <1289801749-8993-1-git-send-email-xiaosuo@gmail.com> <4CE1150D.1080302@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4CE1150D.1080302@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 15, 2010 at 7:10 PM, Patrick McHardy <kaber@trash.net> wrote:
> On 15.11.2010 07:15, Changli Gao wrote:
>> We'd better guard the size of the nf_ct_ext, as the nf_ct_ext.len is u8.
>> If the size is bigger than 255, a warning will be printed.
>
> Why are you checking this in basically every possible spot?
> Just checking once during registration (assuming the worst
> case of a conntrack using every possible extension) should
> be enough.
>

Yes. It is enough, if we check every patch carefully. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
