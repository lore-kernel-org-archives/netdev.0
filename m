From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe function
Date: Thu, 10 Nov 2016 12:09:58 +0100
Message-ID: <87a8d7h9q1.fsf@miraculix.mork.no>
References: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
        <1478692735.2428.10.camel@suse.com> <8760nwj0l3.fsf@miraculix.mork.no>
        <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oneukum@suse.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Kai-Heng Feng <kai.heng.feng@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:33361 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755230AbcKJLLU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 06:11:20 -0500
In-Reply-To: <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
        (Kai-Heng Feng's message of "Thu, 10 Nov 2016 12:06:31 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kai-Heng Feng <kai.heng.feng@canonical.com> writes:
> On Wed, Nov 9, 2016 at 8:32 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>> Oliver Neukum <oneukum@suse.com> writes:
>>
>>> On Tue, 2016-11-08 at 13:44 -0500, Alan Stern wrote:
>>>
>>>> These problems could very well be caused by running at SuperSpeed
>>>> (USB-3) instead of high speed (USB-2).
>
> Yes, it's running at SuperSpeed, on a Kabylake laptop.
>
> It does not have this issue on a Broadwell laptop, also running at SuperS=
peed.

Then I must join Oliver, being very surprised by where in the stack you
attempt to fix the issue.  What you write above indicates a problem in
pci bridge or usb host controller, doesn't it?


Bj=C3=B8rn
