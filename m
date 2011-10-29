From: Taehun Kim <kth3321@gmail.com>
Subject: Re: [PATCH net-next] w5300: add WIZnet W5300 Ethernet driver
Date: Sun, 30 Oct 2011 03:29:59 +0900
Message-ID: <CAOkfWjf722hrPs4_Sj2vACHMD_8UaEx7pHN6JaLZ+ysFdaELcg@mail.gmail.com>
References: <1319272916-5541-1-git-send-email-kth3321@gmail.com>
	<20111024.182142.2299822581628382143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, suhwan@wiznet.co.kr, bongbong@wiznet.co.kr
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111024.182142.2299822581628382143.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/10/25 David Miller <davem@davemloft.net>:
> From: Taehun Kim <kth3321@gmail.com>
> Date: Sat, 22 Oct 2011 17:41:56 +0900
>
>> +struct wiz_private {
>> + =C2=A0 =C2=A0 void __iomem *base;
>> + =C2=A0 =C2=A0 struct net_device *dev;
>> + =C2=A0 =C2=A0 u8 rxbuf_conf[MAX_SOCK_NUM];
>> + =C2=A0 =C2=A0 u8 txbuf_conf[MAX_SOCK_NUM];
>> + =C2=A0 =C2=A0 struct net_device_stats stats;
>> + =C2=A0 =C2=A0 struct napi_struct napi;
>> + =C2=A0 =C2=A0 spinlock_t lock;
>> + =C2=A0 =C2=A0 u32 msg_enable;
>> +};
>
> You don't need to have a private net_device_stats, just use the
> one in struct net_device, and then you can also get rid of your
> private ->ndo_get_stats() method.
>

Thank you for your feedback :)

I am working on this drive by referencing other Ethernet drivers.
I have one question.

Should I suggest the updated driver patch to this thread or new
thread?
