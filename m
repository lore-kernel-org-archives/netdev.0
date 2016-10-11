From: Chris Rorvick <chris@rorvick.com>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Tue, 11 Oct 2016 09:27:36 -0500
Message-ID: <CAEUsAPYOnSu5x3oak380YzrJPM3_N1bz2efkZQZ-8vLeTD286Q@mail.gmail.com>
References: <20161010071943.4717-1-chris@rorvick.com> <1476108164.5210.11.camel@coelho.fi>
 <1476180668.17022.21.camel@tiscali.nl> <CAEUsAPYDPCP0NBaTmy4xqFJhAS4xFQYinoNTknxFT23ef0dk4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Luca Coelho <luca@coelho.fi>,
        Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEUsAPYDPCP0NBaTmy4xqFJhAS4xFQYinoNTknxFT23ef0dk4w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 11, 2016 at 9:09 AM, Chris Rorvick <chris@rorvick.com> wrote:
> I didn't receive your email so I'll try to respond via Paul's.

>>> If this is really bothering you, I guess I could apply this patch for
>>> now.  But as I said, this is not solving the actual problem.
>>
>> Bikeshedding: I think IWL_INFO() is more appropriate, as info doesn't
>> imply one needs to act on this message, while warn does imply that
>> action is needed.
>
> Agreed.  I still think making this a warning is appropriate, but it
> seems pretty clear this is not an error.  This has nothing to do with
> how much it bothers me.  An error tells the user something needs to be
> fixed, but in this case the interface is working fine.  Making it a
> warning with an improved message will result in fewer people wasting
> their time.

I found your original email on lkml.org... should have looked there in
the first place!  Yes, if there is a fix for the underlying issue then
that is obviously preferred.  When I investigated this I saw several
reports spanning at least a few distros and kernel versions with at
least some concluding "this is normal".

Again, thanks!

Chris
