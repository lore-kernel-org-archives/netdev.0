From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next 12/12] ixgbe: update ntuple filter configuration
Date: Thu, 6 Jan 2011 20:12:00 -0800
Message-ID: <AANLkTi=yczts7TSHwGcbZ-gyyhOi+ya0byC6R4f80c1A@mail.gmail.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1294360199-9860-13-git-send-email-jeffrey.t.kirsher@intel.com>
	<1294362158.11825.78.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59689 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab1AGEMB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 23:12:01 -0500
Received: by wyb28 with SMTP id 28so17051532wyb.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 20:12:00 -0800 (PST)
In-Reply-To: <1294362158.11825.78.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 6, 2011 at 5:02 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Thu, 2011-01-06 at 16:29 -0800, jeffrey.t.kirsher@intel.com wrote:
>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>
>> This change fixes several issues found in ntuple filtering while I w=
as
>> doing the ATR refactor.
>>
>> Specifically I updated the masks to work correctly with the latest v=
ersion
>> of ethtool,
> [...]
>
> Did the previous code not correctly handle a zero value with a non-ze=
ro
> mask for some fields? =A0If so, I can revert that change to ethtool.
>
> Ben.

Actually I think the ethtool mention doesn't really apply to the
in-kernel driver. I think I just carried that over from the check-in
for our out of tree driver which hadn't been updated when you added
the code to cleanup the rx ntuple filters.  Also for the driver I'm
not too worried about what the status of it was before since there are
blatant errors in bit/byte ordering and mask bit values in the code
that from what I can tell would have significantly diminished the
usability of the filters.

Thanks,

Alex
