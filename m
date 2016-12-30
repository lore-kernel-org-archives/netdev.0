From: Thomas Preisner <thomas.preisner+linux@fau.de>
Subject: Re: Re: [PATCH v3 2/2] drivers: net: ethernet: 3com: fix return value
Date: Fri, 30 Dec 2016 03:37:52 +0100
Message-ID: <1483065474-11512-1-git-send-email-thomas.preisner+linux@fau.de>
References: <1482873453.20986.4.camel@dillow-glaptop.roam.corp.google.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-kernel@i4.cs.fau.de, milan.stephan+linux@fau.de,
        thomas.preisner+linux@fau.de, sergei.shtylyov@cogentembedded.com,
        davem@davemloft.net
To: dave@thedillows.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482873453.20986.4.camel@dillow-glaptop.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-12-27 at 22:17:35 +0100, David Dillow wrote:
>On Sun, 2016-12-25 at 01:30 +0100, Thomas Preisner wrote:
>> In some cases the return value of a failing function is not being used
>> and the function typhoon_init_one() returns another negative error
>> code instead.
>
>I'm not sure these changes are especially valuable, since we'll need to
>look at the dmesg log anyways to figure out what went wrong, but again I
>don't feel strongly.
>
>Fix up the subject issues and I'm happy to ack them.

As requested, here are the patchsets with the fixed subjects.
The subjects aswell as the subject prefixes are more precise now.
Hopefully that's ok.

Patch 1:
Makes the function typhoon_init_one() return a negative error code instead of 0.

Patch 2 [Optional]:
Makes the function typhoon_init_one() return the return value of the
corresponding failing function calls instead of a "fixed" negative error code.

With Regards,
Milan and Thomas
