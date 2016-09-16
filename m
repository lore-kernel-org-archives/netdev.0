From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH v2] iproute2: build nsid-name cache only for commands that
 need it
Date: Fri, 16 Sep 2016 14:25:40 +0300
Message-ID: <CAMw6YJJbx1HvkiPALfzVarRgeUyWjZ4K_Mrzz2VDH7yfoAg+7w@mail.gmail.com>
References: <20160916072225.GA10536@toys.tundra.dog-lvm.novalocal>
 <1cced3be-a4d4-ef04-6079-e65755d9975b@6wind.com> <CAMw6YJJuoA+Z_DQx8iSEkrurB4ZZN9MePtHEeW=q7t5aDvmSAA@mail.gmail.com>
 <905de9c1-1322-5468-5770-58f788cb972c@6wind.com> <CAAL2ahKKFWcxhA=k+=3Td8sb-upnRUFs373EOhkHDaxvcgYjOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Anton Aksola <aakso@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33436 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933839AbcIPLZm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 07:25:42 -0400
Received: by mail-wm0-f67.google.com with SMTP id b187so3257755wme.0
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 04:25:42 -0700 (PDT)
In-Reply-To: <CAAL2ahKKFWcxhA=k+=3Td8sb-upnRUFs373EOhkHDaxvcgYjOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2016 at 2:21 PM, Anton Aksola <aakso@iki.fi> wrote:
> Ok, I will post a new patch version. Should tests be posted in a separate
> patch?
>
> 2016-09-16 12:44 GMT+03:00 Nicolas Dichtel <nicolas.dichtel@6wind.com>:
>>
>> Le 16/09/2016 =C3=A0 11:23, Vadim Kochan a =C3=A9crit :
>> [snip]
>> > Would it be useful to add test for this case into testsuite/ ?
>> Yes, it's a good idea.
>>
>> Regards,
>> Nicolas
>
>

Anton, I just looked into tests after when I did post here. I am not
sure it will be trivial,
currently tests are running within separated network namespace by
default (which I did) via
'unshare' tool, and now I see that it is better to call it explicitly
from the each test case. So
I am not sure netns related  tests might be valid if they will be ran
after 'unshare -n', if yes - then there is no problem, otherwise
it needs to be fixed somehow - I will try to do this.

Regards,
Vadim Kochan
