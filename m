From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] packet: tpacket_snd(): fix signed/unsigned comparison
Date: Wed, 29 Jul 2015 00:10:36 -0700 (PDT)
Message-ID: <20150729.001036.271920963041164246.davem@davemloft.net>
References: <1438081021-1321-1-git-send-email-al.drozdov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, edumazet@google.com, willemb@google.com,
	viro@zeniv.linux.org.uk, eyal.birger@gmail.com, mst@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: al.drozdov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438081021-1321-1-git-send-email-al.drozdov@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexander Drozdov <al.drozdov@gmail.com>
Date: Tue, 28 Jul 2015 13:57:01 +0300

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

Applied, thanks.
