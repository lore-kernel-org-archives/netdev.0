From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Wed, 22 Oct 2014 14:15:18 +0300
Message-ID: <544791C6.1080604@mellanox.com>
References: <CAHTgTXVn1479XCoh1-j=Xghtad3zA-hf0za5r_AyoaKuKeFZ2g@mail.gmail.com>	<CAHA+R7MSiuazaAr-F5UGZ+DYv-8EE5mLmVtvjVvfC7iYY9+i=Q@mail.gmail.com> <CAJ3xEMiOEZ9fDtLd4qqPmqAGb3hZneBXidyaxA9Pv1Ki6cKnAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Cong Wang <cwang@twopensource.com>,
	Vinson Lee <vlee@twopensource.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"Jack Morgenstein" <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	netdev <netdev@vger.kernel.org>, <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:50205 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932474AbaJVLPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 07:15:50 -0400
In-Reply-To: <CAJ3xEMiOEZ9fDtLd4qqPmqAGb3hZneBXidyaxA9Pv1Ki6cKnAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2014 7:17 AM, Or Gerlitz wrote:
> On Wed, Oct 22, 2014 at 2:15 AM, Cong Wang <cwang@twopensource.com> wrote:
>> On Sat, Oct 18, 2014 at 2:14 PM, Vinson Lee <vlee@twopensource.com> wrote:
>>> Hi.
>>>
>>> Please consider backporting upstream commit
>>> 2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
>>> race" to stable kernels <= 3.11.
>>>
>>
>> David, could you take care of it if you have time? It fixes a real
>> bug in production. :)
> 
> Let out folks here look on that 1st.
> 
> Or.
> 
Verified patch above [1] on 3.10.y (v3.10.58) as is.

Dave, please pull it to stable 3.10

I don't know about an LTS 3.11 kernel - but if there is such an option,
I verified that the patch also applies cleanly on 3.11.y.

Thanks,
Amir

[1] - 2d4b646 ("net/mlx4_en: Fix BlueFlame race")
