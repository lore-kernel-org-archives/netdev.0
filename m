From: Chris Rorvick <chris@rorvick.com>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Tue, 11 Oct 2016 23:32:47 -0500
Message-ID: <CAEUsAPbEf=hr1ki267qKpenWW_UBO93KY8q6-EdqWpk15Yhcnw@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476180668.17022.21.camel@tiscali.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 11, 2016 at 5:11 AM, Paul Bolle <pebolle@tiscali.nl> wrote:
> For what it's worth, on my machine I have twenty (!) SPLX entries, all
> reading:
>     Name (SPLX, Package (0x04)
>     {
>         Zero,
>         Package (0x03)
>         {
>             0x80000000,
>             0x80000000,
>             0x80000000
>         },
>
>         Package (0x03)
>         {
>            0x80000000,
>            0x80000000,
>            0x80000000
>         },
>
>         Package (0x03)
>         {
>             0x80000000,
>             0x80000000,
>             0x80000000
>         }
>     })

I actually see exactly the same on my Dell XPS 13 (9350) when I  use
acpidump, etc.  I typed the entry I included in the commit log by hand
based on what the driver gets back from the SPLC method (I added a
function to dump the returned object.)

Chris
