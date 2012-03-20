From: Mohammed Shafi <shafi.wireless@gmail.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024
 AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
Date: Tue, 20 Mar 2012 12:02:40 +0530
Message-ID: <CAD2nsn0toAjyWw48J7oREES0=x6D72hMntP+WpAjHmR5drd-tQ@mail.gmail.com>
References: <4F576FD5.2050208@gmail.com>
	<CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com>
	<4F577D9B.7020402@gmail.com>
	<4F579A88.6030503@openwrt.org>
	<4F61F551.5010608@gmail.com>
	<4F639851.5080500@gmail.com>
	<4F674616.8080103@gmail.com>
	<CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com>
	<4F674FF5.2060406@gmail.com>
	<4F6751B2.1030809@openwrt.org>
	<4F681B78.9000207@gmail.com>
	<CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com>
	<4F68235C.5090701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>, linux-kernel@vger.kernel.org,
	Linux-netdev <netdev@vger.kernel.org>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F68235C.5090701@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2012 at 11:57 AM, Justin P. Mattock
<justinmattock@gmail.com> wrote:
> On 03/19/2012 11:19 PM, Mohammed Shafi wrote:
>>>
>>> (gdb) list *ath9k_tx+start+0x284
>>> No symbol "start" in current context.
>>
>>
>> hey, pls try l *(ath9k_tx_start+0x284), yesterday i did the same in
>> the latest wireless testing tree it pointed to line 1929 of xmit.c
>>
>> sc->tx.seq_no +=3D0x10;
>>
>> also did few suspend/resume in my machine, nothing interesting happe=
ned
>>
>>>
>>> before receiving the email to do the above code with gdb I had clea=
ned
>>> the
>>> tree out with git clean -fx so rebuilding might have misalighned
>>> things(but
>>> could be wrong)..
>>>
>>
>>
>>
>
>
> seems gdb is not working with that code but works if I remove _start.
> (maybe -next took this out or something)
>
> (gdb) l *(ath9k_tx_start+0x284)
> No symbol "ath9k_tx_start" in current context.

sorry its
 l *(ath_tx_start+0x284)

> (gdb) l *(ath9k_tx+0x284)
> 0x4854 is in ath_paprd_activate (drivers/net/wireless/ath/ath9k/main.=
c:395).
> 390 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> 391
> 392 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ar9003_paprd_populate_sin=
gle_table(ah, caldata,
> chain);
> 393 =A0 =A0 =A0 =A0 =A0 =A0 }
> 394
> 395 =A0 =A0 =A0 =A0 =A0 =A0 ar9003_paprd_enable(ah, true);
> 396 =A0 =A0 =A0 =A0 =A0 =A0 ath9k_ps_restore(sc);
> 397 =A0 =A0 }
> 398
> 399 =A0 =A0 static bool ath_paprd_send_frame(struct ath_softc *sc, st=
ruct
> sk_buff *skb, int chain)
>
> right now I am running next, will wait for the RX DMA to get a clean =
trace,
> then will look to see.. as for the other issue I just rebooted and hi=
t this
> during bootup.
>
> Justin P. Mattock



--=20
thanks,
shafi
