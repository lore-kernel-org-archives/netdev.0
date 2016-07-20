From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net/mlx5e: Fix del vxlan port command
Date: Wed, 20 Jul 2016 19:30:31 +0300
Message-ID: <CALzJLG-rLr2iwSH8GwEDWhLjn1ZPW=y=A0K=fw=a_rijgX0ZFQ@mail.gmail.com>
References: <1469026128-15975-1-git-send-email-saeedm@mellanox.com> <20160720161517.GC76501@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matthew Finlay <matt@mellanox.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:34641 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbcGTQav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 12:30:51 -0400
Received: by mail-yw0-f180.google.com with SMTP id z8so28298103ywa.1
        for <netdev@vger.kernel.org>; Wed, 20 Jul 2016 09:30:51 -0700 (PDT)
In-Reply-To: <20160720161517.GC76501@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 20, 2016 at 7:15 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Wed, Jul 20, 2016 at 05:48:48PM +0300, Saeed Mahameed wrote:
>> mlx5e_vxlan_core_del_port_cmd cleared the wrong address, the address of
>> the pointer of the buffer rather than clearing the buffer itself.
>>
>> This can lead to a serious stack corruption.
>
> The change is fine, but commit log is complete nonsense.
> Nacking to make sure it's adjusted.
> We cannot have such commits in the git history.

That was my hunch too :) , will fix this.
