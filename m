From: Chris Rorvick <chris@rorvick.com>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Tue, 11 Oct 2016 09:09:57 -0500
Message-ID: <CAEUsAPYDPCP0NBaTmy4xqFJhAS4xFQYinoNTknxFT23ef0dk4w@mail.gmail.com>
References: <20161010071943.4717-1-chris@rorvick.com> <1476108164.5210.11.camel@coelho.fi>
 <1476180668.17022.21.camel@tiscali.nl>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f194.google.com ([209.85.213.194]:35686 "EHLO
        mail-yb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbcJKOKH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 10:10:07 -0400
In-Reply-To: <1476180668.17022.21.camel@tiscali.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Luca,

I didn't receive your email so I'll try to respond via Paul's.

On Tue, Oct 11, 2016 at 5:11 AM, Paul Bolle <pebolle@tiscali.nl> wrote:
>> This is not coming from the NIC itself, but from the platform's ACPI
>> tables.  Can you tell us which platform you are using?

Interesting.  I'm running a Dell XPS 13 9350.  I replaced the
factory-provided Broadcom card with an AC 8260.  I can update the
commit log to reflect this.

>> There are other things that look a bit inconsistent in this code...
>> I'll try to find the official ACPI table definitions for this entries
>> to make sure it's correct.
>
> When I looked into this error, some time ago, I searched around a bit
> for documentation on this splx stuff. Sadly, commit bcb079a14d75
> ("iwlwifi: pcie: retrieve and parse ACPI power limitations") provides
> very few clues and my searches turned up nothing useful. So a pointer
> or two would be really appreciated.

Ditto.

>> If this is really bothering you, I guess I could apply this patch for
>> now.  But as I said, this is not solving the actual problem.
>
> Bikeshedding: I think IWL_INFO() is more appropriate, as info doesn't
> imply one needs to act on this message, while warn does imply that
> action is needed.

Agreed.  I still think making this a warning is appropriate, but it
seems pretty clear this is not an error.  This has nothing to do with
how much it bothers me.  An error tells the user something needs to be
fixed, but in this case the interface is working fine.  Making it a
warning with an improved message will result in fewer people wasting
their time.

Thanks!

Chris
