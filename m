From: Michael Kerrisk <mtk.manpages@gmail.com>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Fri, 23 Sep 2011 07:27:29 +0200
Message-ID: <CAKgNAkh-rAAU+Y4wdLNr1JOk3SWrRH8=MNqdWO6Pmcf=Mz4KxQ@mail.gmail.com>
References: <20110919121940.GA19942@synalogic.ca> <20110919130313.GA27819@hmsreliant.think-freely.org>
 <CAKgNAkgWRdkxgTXNnMi4PVGGsOd-8EHF1siBrk-Bj=rnYenVmQ@mail.gmail.com>
 <20110920132954.GA23041@synalogic.ca> <20110920133837.GA16323@hmsreliant.think-freely.org>
 <20110920141234.GA23164@synalogic.ca> <20110920143109.GB16323@hmsreliant.think-freely.org>
 <CAKgNAkiSrGdXd2e1dpcC0fPmARRwkMrUvB8vCJ7eQ8SYsCuuUw@mail.gmail.com> <20110922124448.GA19801@synalogic.ca>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>, linux-man@vger.kernel.org,
	netdev@vger.kernel.org
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47969 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588Ab1IWF1t convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2011 01:27:49 -0400
In-Reply-To: <20110922124448.GA19801@synalogic.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HI Ben, Neil,

On Thu, Sep 22, 2011 at 2:44 PM, Benjamin Poirier
<benjamin.poirier@gmail.com> wrote:
> On 11-09-22 06:15, Michael Kerrisk wrote:
>> Ben, Neil,
>>
> [snip]
>>
>> Ben, thanks for writing this, and Neil, thanks for reviewing it. I'v=
e
>> applied that change for man-pages-3.34.
>>
>> Ben, I added one small piece ti the description of
>> /proc/sys/net/ipv4/ip_no_pmtu_disc. For completeness, I've reproduce=
d
>> the entire text below. Perhaps you could take a quick scan, to make
>> sure that the changed text is consistent with the whole piece.
>>
>> Thanks,
>>
>> Michael
>>
>> =A0 =A0 =A0 =A0IP_MTU_DISCOVER (since Linux 2.2)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 Set or receive the Path =A0MTU =A0Discov=
ery =A0setting =A0for =A0a
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 socket. =A0 When enabled, Linux will per=
form Path MTU Dis-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 covery as defined in RFC 1191 =A0on =A0S=
OCK_STREAM =A0sockets.
>
> Oops, seems like there's a repetition that crept in here. I'd keep on=
ly
> the first of those two sentences:

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 For =A0non-SOCK_STREAM =A0sockets, IP_PM=
TUDISC_DO forces the
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 don't-fragment flag to be set on all =A0=
outgoing =A0packets.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 The =A0don't-fragment =A0flag =A0is =A0s=
et on all outgoing data-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 grams.

Thanks for catching that! The second of the above sentences is now gone=
=2E

>>                It is the user's responsibility to packetize the
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 data =A0in =A0MTU-sized =A0chunks and to=
 do the retransmits if
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 necessary. =A0The kernel will reject (wi=
th EMSGSIZE) data-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 grams =A0 that =A0 are =A0bigger =A0than=
 =A0the =A0known =A0path =A0MTU.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_PMTUDISC_WANT will =A0fragment =A0a =A0=
datagram =A0if =A0needed
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 according =A0to =A0the path MTU, or will=
 set the don't-frag-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ment flag otherwise.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 The system-wide default can be toggled b=
etween IP_PMTUD-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ISC_WANT =A0and IP_PMTUDISC_DONT by writ=
ing (respectively,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 zero =A0 =A0 =A0and =A0 =A0 =A0nonzero =A0=
 =A0 =A0values) =A0 =A0 =A0to =A0 =A0 =A0the
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /proc/sys/net/ipv4/ip_no_pmtu_disc file.
>
> I think it's a welcome clarification. Is is normal that IP_PMTUDISC_W=
ANT
> gets hyphenated?

That's just an artifact of groff formatting. One can prevent it, but
then the text justification of some lines starts to look very weird.

>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 Path MTU discovery flags =A0 Meaning
>
> I agree with what Neil said about "flags" here. setsockopt(2) calls
> these "option values".

Changed this to just "value".

> Other than that, LGTM
> Acked-by: Benjamin Poirier <benjamin.poirier@gmail.com>
>
> Thanks Michael,
> -Ben

You're welcome. Thanks for taking the time to write the text and check =
my work.

Cheers,

Michael


>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_PMTUDISC_WANT =A0 =A0 =A0 =A0 =A0 Use=
 per-route settings.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_PMTUDISC_DONT =A0 =A0 =A0 =A0 =A0 Nev=
er do Path MTU Discovery.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_PMTUDISC_DO =A0 =A0 =A0 =A0 =A0 =A0 A=
lways do Path MTU Discovery.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_PMTUDISC_PROBE =A0 =A0 =A0 =A0 =A0Set=
 DF but ignore Path MTU.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 When PMTU discovery is enabled, the kern=
el automatically
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 keeps track of the path MTU per destinat=
ion host. =A0 When
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 it =A0is connected to a specific peer wi=
th connect(2), the
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 currently known path MTU can be =A0retri=
eved =A0conveniently
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 using =A0the IP_MTU socket option (e.g.,=
 after an EMSGSIZE
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 error occurred). =A0The path MTU =A0may =
=A0change =A0over =A0time.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 For =A0connectionless =A0sockets with ma=
ny destinations, the
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 new MTU for a given destination =A0can =A0=
also =A0be =A0accessed
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 using =A0the =A0error =A0queue =A0(see I=
P_RECVERR). =A0A new error
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 will be queued for every incoming MTU up=
date.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 While MTU discovery is in progress, init=
ial packets from
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 datagram sockets may be dropped. =A0Appl=
ications using UDP
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 should be aware of this and not take it =
into account for
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 their packet retransmit strategy.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 To =A0bootstrap =A0the =A0path MTU disco=
very process on uncon-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nected sockets, it is possible to start =
with a big data-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 gram =A0size =A0(up =A0to =A064K-headers=
 =A0bytes long) and let it
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 shrink by updates of the path MTU.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 To get an initial estimate of the path =A0=
MTU, =A0connect =A0a
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 datagram =A0socket =A0to =A0the destinat=
ion address using con-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 nect(2) and retrieve the MTU =A0by =A0ca=
lling =A0getsockopt(2)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 with the IP_MTU option.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 It =A0is =A0possible =A0to implement RFC=
 4821 MTU probing with
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 SOCK_DGRAM or SOCK_RAW sockets by =A0set=
ting =A0a =A0value =A0of
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 IP_PMTUDISC_PROBE =A0(available since Li=
nux 2.6.22). =A0This
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 is also particularly useful for diagnost=
ic tools such as
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 tracepath(8) =A0that wish to deliberatel=
y send probe pack-
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ets larger than the observed Path MTU.
>>
>>
>> --
>> Michael Kerrisk
>> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
>> Author of "The Linux Programming Interface"; http://man7.org/tlpi/
>



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
