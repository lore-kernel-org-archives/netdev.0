From: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 16:26:30 +0100
Message-ID: <b98e548c0812040726w6ac94d66x8d9f2b1b4aaf7068@mail.gmail.com>
References: <b98e548c0812030637j2851ed76xb0768932b434e35c@mail.gmail.com>
	 <b98e548c0812030812i3980791y2e4135cb9c5110c0@mail.gmail.com>
	 <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:7649 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbYLDP0d convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 10:26:33 -0500
Received: by nf-out-0910.google.com with SMTP id d3so2138743nfc.21
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2008 07:26:30 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0812041419500.26947@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 4, 2008 at 1:41 PM, Ilpo J=E4rvinen <ilpo.jarvinen@helsinki=
=2Efi> wrote:
> On Wed, 3 Dec 2008, Saverio Mascolo wrote:
>
>> we have added plots of cwnd at
>>
>> http://c3lab.poliba.it/index.php/TCP_over_Hsdpa
>>
>> in the case of newreno, wetwood+, bic/cubic.
>
> You lack the most important detail, ie., the used kernel versions!

2.6

>And
> also information if some sysctls were tuned or not. This is especiall=
y
> important since you seem to claim that bic is the default which it ha=
sn't
> been for years?!

bic is default since a couple of years, at my by knoweledge. btw now it=
 is.

>
>> basically the goodput is similar with all variants  but with
>> significantly larger packet losses and timeouts with bic/cubic.
>
> I've never understood what exactly is wrong with the larger amount of
> packet losses if they happen before (or at the bottleneck), here they=
're
> just a consequence of having the larger window.

what matters is goodput. if protocols A and B provide same goodput the
better is the one with lowest retransmissions because retrans. waste
bandwidth


>
>> i am pretty sure that this would happen with any algos -including h-=
tcp-
>> that makes the probing more aggressive leaving the van jacobson line=
ar
>> phase.
>
> Probably, but you seem to completely lack the analysis to find out wh=
y the
> rtos did actually happen, whether it was due to most of the window lo=
st or
> perhaps spurious rtos?

using a more aggressive probing (more than linear) increases retransmis=
sions.

sm
>
>
> --
>  i.
>



--
Prof. Saverio Mascolo
Dipartimento di Elettrotecnica ed Elettronica
Politecnico di Bari
Via Orabona 4
70125 Bari
Italy
Tel. +39 080 5963621
=46ax. +39 080 5963410
email:mascolo@poliba.it

http://www-dee.poliba.it/dee-web/Personale/mascolo.html


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
This message may contain confidential and/or legally privileged informa=
tion.
 If you are not the intended recipient of the message, please destroy i=
t.
Any unauthorized dissemination, distribution, or copying of the materia=
l in
this message, and any attachments to the message, is strictly forbidden=
=2E
