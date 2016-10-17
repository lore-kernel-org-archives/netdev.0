From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: Re: [PATCH v4] mac80211: move extra crypto data off the stack
Date: Mon, 17 Oct 2016 11:02:53 +0100
Message-ID: <41D0AC2F-E86E-4A98-AD8B-1239D7E6123A@linaro.org>
References: <1476693195-14071-1-git-send-email-johannes@sipsolutions.net> <CAKv+Gu-aZhCBvnEQoZUZLDPXCrvgxO1pSd=6EHz+tMB+dFz5hg@mail.gmail.com> <1476696226.19992.13.camel@sipsolutions.net> <CAKv+Gu_ZH9hO_xbVfOfk90CxFJ6ZTz3PKWB1v23LRVzpBrb=oQ@mail.gmail.com> <1476696918.19992.15.camel@sipsolutions.net> <67161BCC-596E-4DDE-A58E-9195BB5570C2@linaro.org> <1476698041.19992.19.camel@sipsolutions.net>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Cc: "<linux-wireless@vger.kernel.org>" <linux-wireless@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "<netdev@vger.kernel.org>" <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:34803 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754520AbcJQKC6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 06:02:58 -0400
Received: by mail-lf0-f54.google.com with SMTP id b81so277161442lfe.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 03:02:58 -0700 (PDT)
In-Reply-To: <1476698041.19992.19.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 17 Oct 2016, at 10:54, Johannes Berg <johannes@sipsolutions.net> wrote:=

>=20
>=20
>>> Well, if your other patch to make it OK to be on-stack would be
>>> applied instead, this wouldn't make much sense either :)
>>>=20
>>=20
>> Yes but that one only fixes ccm not gcm
>=20
> Yes, but we can do the same for GCM, no?
>=20

No, not really. ccm happens to use aes with the same key for the mac and the=
 encryption. gcm uses an another algo entirely for the mac

>>> In this particular patch, we could reduce the size of the struct,
>>> but I
>>> don't actually think it'll make a difference to go from 48 to 36
>>> bytes,
>>> given alignment etc., so I think I'll just leave it as is.
>>>=20
>>=20
>> I understand you are in a hurry, but this is unlikely to be the only
>> such issue. I will propose an 'auxdata' feature for the crypto api
>> that can be used here, but also for any other occurrence where client
>> data assoiciated with the request can no longer be allocated on the
>> stack
>=20
> No objections. I'll merge this anyway today I think, reverting is easy
> later.
>=20

ok fair enough=
