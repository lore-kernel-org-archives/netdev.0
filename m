From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>
Subject: Re: [PATCH] iwlwifi: Demote messages about fw flags size to info
Date: Tue, 1 Aug 2017 15:58:47 -0700
Message-ID: <CAOcMMifW4mVPj1TVkzQPdvT0YO6p1DUObNinzWv2_ZtCbfk9Mg@mail.gmail.com>
References: <20170721145147.7572-1-jprvita@endlessm.com> <1500894086.20057.12.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: linuxwifi <linuxwifi@intel.com>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "jprvita@gmail.com" <jprvita@gmail.com>,
        "Berg, Johannes" <johannes.berg@intel.com>,
        "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "linux@endlessm.com" <linux@endlessm.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Coelho, Luciano" <luciano.coelho@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36138 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750979AbdHAW6s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 18:58:48 -0400
Received: by mail-pf0-f173.google.com with SMTP id z129so13400291pfb.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 15:58:48 -0700 (PDT)
In-Reply-To: <1500894086.20057.12.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Luca,

On Mon, Jul 24, 2017 at 4:01 AM, Coelho, Luciano
<luciano.coelho@intel.com> wrote:
> On Fri, 2017-07-21 at 07:51 -0700, Jo=C3=A3o Paulo Rechi Vita wrote:

(...)

>> Currently these messages are presented to the user during boot if there
>> is no bootsplash covering the console, sometimes even if the boot splash
>> is enabled but has not started yet by the time this message is shown.
>>

I should have provided another piece of information here: all of this
happens even when booting with the 'quiet' kernel parameter.

> This specific case is harmless, but I'd rather keep this message as an
> error, because in other situations it could lead to unexpected
> behavioir, so I prefer to keep it very visible.
>
>

I see your point, and I understand the purpose of these messages. I'm
wondering if perhaps having them at the warning level would give them
enough visibility, while still keeping a clean boot process to the end
user. If so, I can send an updated patch.

Thanks for your reply and for pointing to the fix for the root cause
of that message.

Cheers,

...........................................................................=
...........
Jo=C3=A3o Paulo Rechi Vita  |  +1.415.851.5778  |  Endless
