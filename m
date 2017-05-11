From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] qed: fix uninitialized data in aRFS intrastructure
Date: Thu, 11 May 2017 17:01:18 +0200
Message-ID: <CAK8P3a00dkyyB7jZ62EDkoFA8=qgboKOMUWP8f2i3s8VOhbtMg@mail.gmail.com>
References: <20170511121633.3591880-1-arnd@arndb.de> <BLUPR0701MB2004E8FA50C46973E09FBA298DED0@BLUPR0701MB2004.namprd07.prod.outlook.com>
 <CAK8P3a2x8OxcoHyx_e1Tj7k5QP5nVvTt3mh5WZvdfMfrZqPw8g@mail.gmail.com> <BLUPR0701MB20046B7EA7273C97047B02F28DED0@BLUPR0701MB2004.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BLUPR0701MB20046B7EA7273C97047B02F28DED0@BLUPR0701MB2004.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 11, 2017 at 4:37 PM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> > For the most part - I'm almost all in favor of this change.
>> > But just to make it clear - the actual fix could have been a one-liner, right?
>> > The rest are style changes.
>
>> Correct. Having the correct length in the memset is a sufficient fix for the warning,
>> but it felt wrong to send it since the root of the problem seems to be the
>> complexity of the code that was hiding it.
>
> ...
>
>> Generally speaking, feel free to treat any of my compile-time warning fix
>> patches as simple bug reports and apply a different fix that seems more
>> appropriate. I mainly send it in patch form since that seems to be the
>> quickest way to address any issues.
>
> Sure.
>
> Once net-next is re-opened I intend to push our next FW version which
> is also going to change some of the aRFS related configurations.
>
> So I think we should stick to the single-liner fix for now,
> and I'll revise the style [if still needed; I'll have to check] on that submission.

Sounds good, thanks!

     Arnd
