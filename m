From: Alexander Popov <alex.popov@linux.com>
Subject: Re: [PATCH 1/1] net: fs_enet: Disable NETIF_F_SG feature for Freescale
 MPC5121
Date: Mon, 15 Jun 2015 05:35:10 +0300
Message-ID: <557E39DE.4070802@linux.com>
References: <1433894262-28900-1-git-send-email-alex.popov@linux.com> <20150609.171441.861174213383180358.davem@davemloft.net>
Reply-To: alex.popov@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pantelis.antoniou@gmail.com, vbordug@ru.mvista.com,
	christophe.leroy@c-s.fr, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150609.171441.861174213383180358.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

10.06.2015 03:14, David Miller =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> From: Alexander Popov <alex.popov@linux.com>
> Date: Wed, 10 Jun 2015 02:57:42 +0300
>
>> skb_copy_from_linear_data() which doesn't work well for non-linear s=
k_buff:
>
> The correct fix is to use an SKB copy routine which can
> handle non-linear data.

Thanks, David.
I'll prepare the second version of the patch.

Best regards,
Alexander
