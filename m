From: Dave Taht <dave.taht@gmail.com>
Subject: Re: Throughput regression with `tcp: refine TSO autosizing`
Date: Thu, 12 Feb 2015 00:33:53 -0800
Message-ID: <CAA93jw7YmnHYXpEitm+Fjm=wP2NaioBs1kotFj5fO-vB_Eu_1g@mail.gmail.com>
References: <CA+BoTQkVu23P3EOmY_Q3E1GJnWsyF==Pawz4iPOS_Bq5dvfO5Q@mail.gmail.com>
	<1422537297.21689.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQk2xT-8DqPuiiKG+kHAjLPrj8F9dLTb-rcGhvMq0u_2Qw@mail.gmail.com>
	<1422628835.21689.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkV+mOZfe_Niz5101sMQeaV6muKCsShptjGQ1AgOHqqoQ@mail.gmail.com>
	<1422903136.21689.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<1422926330.21689.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkMikA8wxm1ce2DkKhPB0HiKeAqT7f+sQ=91W40z=X0Rg@mail.gmail.com>
	<1422973660.907.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmvUuFdfYF=wVMYxrf_nQZB5GCV=LvDZVvfs-3hAE4WKw@mail.gmail.com>
	<1423051045.907.108.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=BDcQ779uKCuX+f40=4npXVF4MTQnpjKimNYAxPsxBoQ@mail.gmail.com>
	<1423053531.907.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=qmCZz4CmSOvCOzMLowrDEG12XBffkTcYxjGqVD9604g@mail.gmail.com>
	<1423055810.907.125.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423056591.907.130.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423084303.31870.15.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQnnwrv0nrKyGyQNvosz_E4e5fBa9iN8fpeqcd-iRfi17g@mail.gmail.com>
	<1423141038.31870.38.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423142342.31870.49.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQmcShK0U_cXvEOLY_8y7LH8x3taTgjcyMzv0MLVn4UtCA@mail.gmail.com>
	<1423147286.31870.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423156205.31870.86.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=WaKLV=r6qWaWAEfyDr2pqMWpm4NDmnek92TEVndnxRQ@mail.gmail.com>
	<1423230001.31870.128.camel@edumazet-glaptop2.roam.corp.google.com>
	<1423230785.31870.131.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQkazCOin7VWLfrHUjtgKDPV6T+sFsk5FPS7D-morr4FZQ@mail.gmail.com>
	<CA+BoTQn3KRym0qCJ+fLav5LQgjfiN_-Eqz0xPSc2eXJ-ijNjQw@mail.gmail.com>
	<1423494690.31870.189.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+BoTQ=u_xPuqTVOVaFTQNRrJ+UTXe89SY+=+7Y1LpxxrkRDfg@mail.gmail.com>
	<1423577962.2215.2.camel@sipsolutions.net>
	<CA+BoTQn=YQQ_yUHvpAG3MMAw+=jxgLDiUMWxiTC3B3vkksTw9g@mail.gmail.com>
	<CA+BoTQnxo-x94uVfErZO43jTowVcEMEt+7xDzoAGiR8fRDv=ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
To: Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:36494 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbbBLIdy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 03:33:54 -0500
In-Reply-To: <CA+BoTQnxo-x94uVfErZO43jTowVcEMEt+7xDzoAGiR8fRDv=ug@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 11, 2015 at 11:48 PM, Michal Kazior <michal.kazior@tieto.co=
m> wrote:
> On 11 February 2015 at 09:57, Michal Kazior <michal.kazior@tieto.com>=
 wrote:
>> On 10 February 2015 at 15:19, Johannes Berg <johannes@sipsolutions.n=
et> wrote:
>>> On Tue, 2015-02-10 at 11:33 +0100, Michal Kazior wrote:
>>>
>>>> +       if (msdu->sk) {
>>>> +               ewma_add(&ar->tx_delay_us,
>>>> +                        ktime_to_ns(ktime_sub(ktime_get(), skb_cb=
->stamp)) /
>>>> +                        NSEC_PER_USEC);
>>>> +
>>>> +               ACCESS_ONCE(msdu->sk->sk_tx_completion_delay_cushi=
on) =3D
>>>> +                               (ewma_read(&ar->tx_delay_us) *
>>>> +                                msdu->sk->sk_pacing_rate) >> 20;
>>>> +       }
>>>
>>> To some extent, every wifi driver is going to have this problem. Pe=
rhaps
>>> we should do this in mac80211?
>>
>> Good point. I was actually thinking about it. I can try cooking a
>> patch unless you want to do it yourself :-)
>
> I've taken a look into this. The most obvious place to add the
> timestamp for each packet would be ieee80211_tx_info (i.e. the
> skb->cb[48]). The problem is it's very tight there. Even squeezing 2
> bytes (allowing up to 64ms of tx completion delay which I'm worried

I will argue strongly in favor of never allowing more than 4ms packets
to accumulate in the firmware.

> won't be enough) will be troublesome. Some drivers already use every
> last byte of their allowance on 64bit archs (e.g. ar5523 uses entire
> 40 bytes of driver_data).
>
> I wonder if it's okay to bump skb->cb to 56 bytes to avoid the cascad=
e
> of changes required to implement the tx completion delay accounting?
>
>
> Micha=C5=82
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Dave T=C3=A4ht

thttp://www.bufferbloat.net/projects/bloat/wiki/Upcoming_Talks
