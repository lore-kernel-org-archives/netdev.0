From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] netfilter: CONNMARK: support save the mark of the master connection
Date: Thu, 27 Jan 2011 18:01:03 +0800
Message-ID: <AANLkTinKHJPEf8EukDGSX=NPMtU9zb7y7GoYwbUQOjt5@mail.gmail.com>
References: <1296121124-7016-1-git-send-email-xiaosuo@gmail.com> <4D413F96.2070309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4D413F96.2070309@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 27, 2011 at 5:49 PM, Patrick McHardy <kaber@trash.net> wrote:
> Am 27.01.2011 10:38, schrieb Changli Gao:
>> In some cases(Policy routing), it is expected that all the sub-connections
>> share the same mark with their master.
>
> We already automatically mark expected connections with the mark of the
> master. What purpose does your patch serve on top of that?
>
>

It is done in init_conntrack(), indeed. Sorry for the noise. Thanks.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
