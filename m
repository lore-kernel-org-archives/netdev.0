From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tulip: delete useless tests on netdev_priv
Date: Fri, 03 Jan 2014 19:35:39 -0500 (EST)
Message-ID: <20140103.193539.332685938065529152.davem@davemloft.net>
References: <1388680129-13661-1-git-send-email-Julia.Lawall@lip6.fr>
	<CAP6odjhqzKPiBdxQVm5BbbOFwiekJu66_WgSE+E4g_nkHh+-dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Julia.Lawall@lip6.fr, grundler@parisc-linux.org,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: grantgrundler@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAP6odjhqzKPiBdxQVm5BbbOFwiekJu66_WgSE+E4g_nkHh+-dQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grantgrundler@gmail.com>
Date: Thu, 2 Jan 2014 07:57:26 -0800

> On Thu, Jan 2, 2014 at 8:28 AM, Julia Lawall <Julia.Lawall@lip6.fr> wrote:
>> From: Julia Lawall <Julia.Lawall@lip6.fr>
>>
>> Netdev_priv performs an addition, not a pointer dereference, so it seems
>> quit unlikely that its result would ever be NULL.
> 
> LGTM.
> 
>  >
>> A semantic patch that makes this change is as follows:
>> (http://coccinelle.lip6.fr/)
>>
>> // <smpl>
>> @@
>> statement S;
>> @@
>>
>> - if (!netdev_priv(...)) S
>> // </smpl>
>>
>> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> 
> Acked-by: Grant Grundler <grundler@parisc-linux.org>

Applied, thanks everyone.
