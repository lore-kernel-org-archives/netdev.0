From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [Linux 4.2-rc8+...v4.3-rc2] REGRESSION: ppp: circular locking
 dependency detected: [pppd] ppp_dev_uninit() | rtnl_lock()
Date: Fri, 25 Sep 2015 07:58:38 +0200
Message-ID: <CA+icZUUYdaiGdE9FNb5ab=srjhavq89NEvryA2pdbMr74BDi+A@mail.gmail.com>
References: <CA+icZUU0rUJZRb4R+F1N98hbfb0rbmbZ0=Jf60zb30SQHKi1Ug@mail.gmail.com>
	<20150924110317.GF2869@alphalink.fr>
	<CA+icZUUcmjxNsMDHuWY9zi9RSBum7hR=HWmWfxs=swRbqm4p7Q@mail.gmail.com>
	<20150924.110055.1257680342513050032.davem@davemloft.net>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: g.nault@alphalink.fr,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150924.110055.1257680342513050032.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 24, 2015 at 8:00 PM, David Miller <davem@davemloft.net> wrote:
> From: Sedat Dilek <sedat.dilek@gmail.com>
> Date: Thu, 24 Sep 2015 18:19:16 +0200
>
>> OK, I guess DaveM will take your patch into net.git#master first...
>> and tag it there with CC-stable?
>
> I do not tag anything with stable.
>
> I queue it up into a patchwork bundle and explicitly submit those
> patches to stable@vger.kernel.org at a time of my own choosing.
>
> This is a FAQ, documented in the kernel Documentation/ subdirectory.

OK, so this is a special handling for netdev?
I normally look at "SubmittingPatches" documentation [1] and looked in
this case especially at [2].
Can you point me to this "FAQ"?

Where do you include Guillaume's patch - in net.git#master?

Since Linux v4.2 my Internet connection via UMTS/HSPA USB modem is "unstable".
For me this is an important fix.

Thanks.

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/SubmittingPatches
[2] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/SubmittingPatches#n297
