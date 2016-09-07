From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/2] lan78xx: Remove trailing underscores from macros
Date: Tue, 06 Sep 2016 19:13:14 -0700
Message-ID: <1473214394.29864.4.camel@perches.com>
References: <cover.1473202982.git.joe@perches.com>
         <9235D6609DB808459E95D78E17F2E43D40910FF9@CHN-SV-EXMX02.mchp-main.com>
        ,<1473211122.29864.1.camel@perches.com>
         <CB1A8EE47AAD7B4897132E685E5108C551F87491@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, UNGLinuxDriver@microchip.com,
        linux-kernel@vger.kernel.org
To: Ronnie.Kunin@microchip.com, Woojung.Huh@microchip.com,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0028.hostedemail.com ([216.40.44.28]:42401 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755437AbcIGCNV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 22:13:21 -0400
In-Reply-To: <CB1A8EE47AAD7B4897132E685E5108C551F87491@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-09-07 at 02:00 +0000, Ronnie.Kunin@microchip.com wrote:
> Microchip's internal convention is for register (offset) definitions
> to be capitalized (i.e.: MY_REGISTER). Our convention for bits
> (position) definitions within a register is to carry as a prefix the
> name of the register and suffix it with the bit name and adding a
> trailing underscore (i.e. MY_REGISTER_MY_BIT_). The trailing
> underscore is what easily lets us distinguish a bit from a register
> definition when reading code. We have been using this convention for
> many years and has worked very well for us across all projects (by now
> hundreds).

I think it's kind of an ugly convention, but <shrug> no
skin off my nose really.

> > Is there anything other than a one-time cost
> > to apply these?  Is the same code used for
> > other platforms?
> 
> Yes, a single header file with the definition of registers and bits is
> shared (either as a standalone file or with its contents pasted into a
> native environment "carrier" header file) across all drivers (and
> other non driver software projects as well) for the same device. So a
> change like this indeed has a high cost for Microchip and we'd rather
> not do this unless it is an absolutely mandated requirement. 

No worries, if you don't like it, don't apply it.

Send a NAK too so David Miller doesn't apply it either.
