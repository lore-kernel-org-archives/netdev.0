From: Luca Coelho <luca@coelho.fi>
Subject: Re: [PATCH] iwlwifi: pcie: reduce "unsupported splx" to a warning
Date: Wed, 12 Oct 2016 15:24:59 +0300
Message-ID: <1476275099.7776.28.camel@coelho.fi>
References: <20161010071943.4717-1-chris@rorvick.com>
         <1476108164.5210.11.camel@coelho.fi> <1476180668.17022.21.camel@tiscali.nl>
         <CAEUsAPbEf=hr1ki267qKpenWW_UBO93KY8q6-EdqWpk15Yhcnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Intel Linux Wireless <linuxwifi@intel.com>,
        Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Oren Givon <oren.givon@intel.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Chris Rorvick <chris@rorvick.com>, Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from paleale.coelho.fi ([176.9.41.70]:48404 "EHLO
        farmhouse.coelho.fi" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752653AbcJLMZH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 08:25:07 -0400
In-Reply-To: <CAEUsAPbEf=hr1ki267qKpenWW_UBO93KY8q6-EdqWpk15Yhcnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-11 at 23:32 -0500, Chris Rorvick wrote:
> On Tue, Oct 11, 2016 at 5:11 AM, Paul Bolle <pebolle@tiscali.nl> wrote:
> > For what it's worth, on my machine I have twenty (!) SPLX entries, all
> > reading:
> >     Name (SPLX, Package (0x04)
> >     {
> >         Zero,
> >         Package (0x03)
> >         {
> >             0x80000000,
> >             0x80000000,
> >             0x80000000
> >         },
> > 
> >         Package (0x03)
> >         {
> >            0x80000000,
> >            0x80000000,
> >            0x80000000
> >         },
> > 
> >         Package (0x03)
> >         {
> >             0x80000000,
> >             0x80000000,
> >             0x80000000
> >         }
> >     })
> 
> 
> I actually see exactly the same on my Dell XPS 13 (9350) when I  use
> acpidump, etc.  I typed the entry I included in the commit log by hand
> based on what the driver gets back from the SPLC method (I added a
> function to dump the returned object.)

Okay... Actually this is a structure in the BIOS and the actual method
we call is SPLC.  The SPLC method may return one item from this table,
or something entirely different, possible one of the three values
depending on a configuration option or so.

Can you to find and send me the actual SPLC method that we call, from
your BIOS?
