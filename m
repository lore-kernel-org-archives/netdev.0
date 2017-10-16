From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Linux 4.12+ memory leak on router with i40e NICs
Date: Mon, 16 Oct 2017 07:11:43 -0700
Message-ID: <CAKgT0UeDKE6ce64+RckJTHpu+=7DZBO0GRc8FBBnkcVTwDC_xA@mail.gmail.com>
References: <1507121766.30720.4.camel@cohaesio.com> <CAKgT0UfAqzuEbFA_hs8f4goL2hTMqeJ5no2sAc8NO_KJO120tA@mail.gmail.com>
 <1507180753.20182.8.camel@cohaesio.com> <227d17ae-b040-07d0-3c57-e9acd1a3b5b4@itcare.pl>
 <c49a750f-c47c-9de0-ebf0-148db5e3d3c5@itcare.pl> <CAKgT0UcOWxnrsGEjTopPP-JKyKGTG3j6KNKUbhQRgaCStyzr_A@mail.gmail.com>
 <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>,
        "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
        David Miller <davem@davemloft.net>
To: Pavlos Parissis <pavlos.parissis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:52187 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752120AbdJPOLp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 10:11:45 -0400
Received: by mail-qk0-f194.google.com with SMTP id 17so12959844qkq.8
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 07:11:44 -0700 (PDT)
In-Reply-To: <b4995fc8-1420-fe96-26f7-ad5d986b7d39@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 16, 2017 at 4:20 AM, Pavlos Parissis
<pavlos.parissis@gmail.com> wrote:
> On 15/10/2017 02:58 =CF=80=CE=BC, Alexander Duyck wrote:
>> Hi Pawel,
>>
>> To clarify is that Dave Miller's tree or Linus's that you are talking
>> about? If it is Dave's tree how long ago was it you pulled it since I
>> think the fix was just pushed by Jeff Kirsher a few days ago.
>>
>> The issue should be fixed in the following commit:
>> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/commit/dri=
vers/net/ethernet/intel/i40e/i40e_txrx.c?id=3D2b9478ffc550f17c6cd8c69057234=
e91150f5972
>>
>
>
> Do you know when it is going to be available on net-next and linux-stable=
 repos?
>
> Cheers,
> Pavlos

Hi Pavos,

My guess would be a week or two for net-next since it normally has to
go from the net tree, into Linus's tree, and then back into net-next.
As far as stable, I believe there is some queue that Dave has to
submit the patch into for that. Beyond that I have no idea what the
timelines are like in order for a patch to make it into any given
stable kernel release.

I added Dave to the Cc since I am kind of guessing at the process and timel=
ines.

Hope that helps.

- Alex
