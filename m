From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] packet: tpacket_snd(): fix signed/unsigned comparison
Date: Tue, 28 Jul 2015 13:07:02 +0200
Message-ID: <55B76256.2040105@iogearbox.net>
References: <1438081021-1321-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eyal Birger <eyal.birger@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexander Drozdov <al.drozdov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438081021-1321-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/28/2015 12:57 PM, Alexander Drozdov wrote:
> tpacket_fill_skb() can return a negative value (-errno) which
> is stored in tp_len variable. In that case the following
> condition will be (but shouldn't be) true:
>
> tp_len > dev->mtu + dev->hard_header_len
>
> as dev->mtu and dev->hard_header_len are both unsigned.
>
> That may lead to just returning an incorrect EMSGSIZE errno
> to the user.
>
> Signed-off-by: Alexander Drozdov <al.drozdov@gmail.com>

Looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
