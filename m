From: Kalle Valo <kvalo@codeaurora.org>
Subject: stable-kernel-rules: wireless and netdev-FAQ
Date: Mon, 04 Sep 2017 15:58:15 +0300
Message-ID: <87ziaaoc2g.fsf_-_@kamboji.qca.qualcomm.com>
References: <b08798d4-21eb-6fda-3972-50bc1f4d0e9a@lwfinger.net>
        <20170831075514.GA12340@redhat.com>
        <26ef3184-a19e-1bb7-7aa4-4e8647210763@lwfinger.net>
        <20170901085738.GA18397@redhat.com> <87y3pymqw2.fsf@purkki.adurom.net>
        <20170902082223.GA11293@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Helmut Schaa <helmut.schaa@googlemail.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170902082223.GA11293@redhat.com> (Stanislaw Gruszka's message
        of "Sat, 2 Sep 2017 10:22:24 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(adding netdev and lkml)

Stanislaw Gruszka <sgruszka@redhat.com> writes:

> On Fri, Sep 01, 2017 at 05:31:57PM +0300, Kalle Valo wrote:
>> Stanislaw Gruszka <sgruszka@redhat.com> writes:
>> 
>> > On Thu, Aug 31, 2017 at 10:33:28AM -0500, Larry Finger wrote:
>> >> Should the patch to wireless-drivers be annotated with a Stable reference so
>> >> that it is added to 4.12 and 4.13?
>> >
>> > According to Documentation/networking/netdev-FAQ.txt networking patches
>> > should not be marked cc:stable, instead a decent commit log should
>> > be written describing a bugfix. Which I believe it is done for
>> > this patch.
>> 
>> But that's for net and net-next trees, not for wireless trees. With
>> wireless patches we use "Cc: stable@..." references.
>
> Oh, ok. I was confused by below part of
> Documentation/process/stable-kernel-rules.rst 
> (because wireless drivers are located in drivers/net/)
>
>  - If the patch covers files in net/ or drivers/net please follow netdev stable
>    submission guidelines as described in
>    Documentation/networking/netdev-FAQ.txt

Yeah, that's confusing and should be clarified that wireless follows
traditional stable process. IIRC bluetooth does the same so it's not
just wireless.

Any volunteers to fix it? :)

-- 
Kalle Valo
