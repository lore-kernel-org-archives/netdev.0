From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [patch -next] udp: fix if statement in SIOCINQ ioctl
Date: Mon, 18 Apr 2016 09:41:03 -0400
Message-ID: <CAF=yD-J3D4HntLHfLjT7_9oj+nWqXjBww3SdNDDSsQxpvfwiUQ@mail.gmail.com>
References: <20160418084449.GA12410@mwanda> <1460981977.10638.105.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460981977.10638.105.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 18, 2016 at 8:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-04-18 at 11:44 +0300, Dan Carpenter wrote:
>> We deleted a line of code and accidentally made the "return put_user()"
>> part of the if statement when it's supposed to be unconditional.
>>
>> Fixes: 9f9a45beaa96 ('udp: do not expect udp headers on ioctl SIOCINQ')
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> Acked-by: Eric Dumazet <edumazet@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>

Thanks for catching this.
