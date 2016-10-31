From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Let's do P4
Date: Mon, 31 Oct 2016 08:47:51 +0100
Message-ID: <20161031074751.GA1679@nanopsycho.orion>
References: <20161029075328.GB1692@nanopsycho.orion>
 <20161029154903.25deb6db@jkicinski-Precision-T1700>
 <5814D25D.9070200@gmail.com>
 <20161030074458.GB1686@nanopsycho.orion>
 <20161030102649.GE1810@pox.localdomain>
 <20161030163836.GC1686@nanopsycho.orion>
 <20161030223903.GA6658@ast-mbp.hil-sfehihf.abq.wayport.net>
 <CAHo-Ooz82uFsf6F=pU-jrR-KOADWuRmkiAfKaB_sQGc=4N7z4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Thomas Graf <tgraf@suug.ch>,
        John Fastabend <john.fastabend@gmail.com>,
        Jakub Kicinski <kubakici@wp.pl>,
        Linux NetDev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        roopa@cumulusnetworks.com, simon.horman@netronome.com,
        ast@kernel.org, daniel@iogearbox.net, prem@barefootnetworks.com,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jiri Benc <jbenc@redhat.com>,
        Tom Herbert <tom@herbertland.com>, mattyk@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, ogerlitz@mellanox.com,
        "John W. Linville" <linville@tuxdriver.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        dsa@c
To: Maciej =?utf-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35178 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761614AbcJaHry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 03:47:54 -0400
Received: by mail-wm0-f48.google.com with SMTP id a197so3853735wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 00:47:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHo-Ooz82uFsf6F=pU-jrR-KOADWuRmkiAfKaB_sQGc=4N7z4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 31, 2016 at 07:03:53AM CET, zenczykowski@gmail.com wrote:
>One thing to consider...
>
>Just because the compiler could be in the kernel, doesn't mean it has to be.
>
>One could envision a hotplug/modprobe like helper program that the
>kernel executes
>when it wants to translate from one encoding (say p4) to another (say [e]bpf).
>
>This keeps complexity (compiler) out of the kernel, while still
>allowing us to have
>the illusion of only one interface to sw/hw.  And it has the nice
>benefit of allowing us
>to use existing compiler toolchains...

This idea was repeatedly marked as unacceptable.
