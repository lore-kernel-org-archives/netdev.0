From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Wed, 18 Oct 2017 16:29:59 -0700
Message-ID: <CAKgT0Udb5DVu6CB5U7rGNERZwMCKZUTii=qxn6hFzc=5zEZc1w@mail.gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com> <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com> <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl> <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com> <3d783736-a474-d9e3-2de2-e35c765f8249@itcare.pl>
 <39696136-2a4a-9c6c-3a63-4485ed2a1bf3@itcare.pl> <20171017055155.GA19944@pc11.op.pod.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        Pavlos Parissis <pavlos.parissis@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:51026 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbdJRXaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 19:30:01 -0400
Received: by mail-qt0-f193.google.com with SMTP id d9so5608294qtd.7
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 16:30:01 -0700 (PDT)
In-Reply-To: <20171017055155.GA19944@pc11.op.pod.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 10:51 PM, Vitezslav Samel <vitezslav@samel.cz> wrot=
e:
> On Tue, Oct 17, 2017 at 01:34:29AM +0200, Pawe=C5=82 Staszewski wrote:
>> W dniu 2017-10-16 o 18:26, Pawe=C5=82 Staszewski pisze:
>> > W dniu 2017-10-16 o 13:20, Pavlos Parissis pisze:
>> > > On 15/10/2017 02:58 =CF=80=CE=BC, Alexander Duyck wrote:
>> > > > Hi Pawel,
>> > > >
>> > > > To clarify is that Dave Miller's tree or Linus's that you are talk=
ing
>> > > > about? If it is Dave's tree how long ago was it you pulled it sinc=
e I
>> > > > think the fix was just pushed by Jeff Kirsher a few days ago.
>> > > >
>> > > > The issue should be fixed in the following commit:
>> > > > https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/comm=
it/drivers/net/ethernet/intel/i40e/i40e_txrx.c?id=3D2b9478ffc550f17c6cd8c69=
057234e91150f5972
>> > >
>> > > Do you know when it is going to be available on net-next and
>> > > linux-stable repos?
>> > >
>> > > Cheers,
>> > > Pavlos
>> > >
>> > >
>> > I will make some tests today night with "net" git tree where this patc=
h
>> > is included.
>> > Starting from 0:00 CET
>> > :)
>> >
>> >
>> Upgraded and looks like problem is not solved with that patch
>> Currently running system with
>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/
>> kernel
>>
>> Still about 0.5GB of memory is leaking somewhere
>>
>> Also can confirm that the latest kernel where memory is not leaking (wit=
h
>> use i40e driver intel 710 cards) is 4.11.12
>> With kernel 4.11.12 - after hour no change in memory usage.
>>
>> also checked that with ixgbe instead of i40e with same  net.git kernel t=
here
>> is no memleak - after hour same memory usage - so for 100% this is i40e
>> driver problem.
>
>   I have (probably) the same problem here but with X520 cards: booting
> 4.12.x gives me oops after circa 20 minutes of our workload. Booting
> 4.9.y is OK. This machine is in production so any testing is very
> limited.
>
>   Machine was stable for >2 months (on the desk before got to
> production) with 4.12.8 but with no traffic on X520 cards.
>
>         Cheers,
>
>                 Vita

Sorry but it can't be the same issue since we are discussing a
different driver (i40e) running different hardware (X710 or XL170).
You might want to start a new thread for your issue, and/or if
possible file a bug on e1000.sf.net.

Thanks.

- Alex
