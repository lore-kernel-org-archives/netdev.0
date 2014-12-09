From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 9 Dec 2014 13:57:27 +0200
Message-ID: <CAJ3xEMjx2qULrgA3SE+xkphyOovqbdSkcAwOsoBsc6s5ZB-erg@mail.gmail.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
	<1416911328-10979-3-git-send-email-jiri@resnulli.us>
	<20141125151312.GC27416@gospo.rtplab.test>
	<20141125151811.GF1971@nanopsycho.orion>
	<5474A391.2080204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:55890 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755617AbaLIL52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 06:57:28 -0500
Received: by mail-ob0-f177.google.com with SMTP id va2so283058obc.8
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 03:57:27 -0800 (PST)
In-Reply-To: <5474A391.2080204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 5:43 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 11/25/2014 07:18 AM, Jiri Pirko wrote:
>>
>> Tue, Nov 25, 2014 at 04:13:12PM CET, gospo@cumulusnetworks.com wrote:
>>>
>>> On Tue, Nov 25, 2014 at 11:28:33AM +0100, Jiri Pirko wrote:
>>>>
>>>> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
>>>> u16 vid to drivers from there.
>>>>
>>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>>
>>>
>>> Structurally this looks fine, just a misspelling noted below.
>>>
>>> Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>
>
> If your going to spin this, should we return an error from
> ndo_dflt_fdb_add() when we have a non-zero vid? The dflt
> handler uses the dev_(mc|uc)_add_excl routines which will
> not consume vids.

so... was this comment addressed along the discussion? I see in the
code that we don't check
on the _dflt_ handlers nor on the per device ones (ixgbe, i40e, qlgc)
for a valid VID and return
error on that.


> If you want to address this with a follow up patch I'm OK
> with that. Go ahead and add my ack,
