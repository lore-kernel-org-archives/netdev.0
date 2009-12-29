From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Mon, 28 Dec 2009 16:42:09 -0800
Message-ID: <9929d2390912281642o964617kbee6e8a2b9f6c75f@mail.gmail.com>
References: <20091228201005.GC18422@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	e1000-devel@lists.sourceforge.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:37771 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbZL2AmK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 19:42:10 -0500
Received: by pxi27 with SMTP id 27so5887471pxi.4
        for <netdev@vger.kernel.org>; Mon, 28 Dec 2009 16:42:10 -0800 (PST)
In-Reply-To: <20091228201005.GC18422@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 12:10, Neil Horman <nhorman@tuxdriver.com> wrot=
e:
> Hey all-
> =C2=A0 =C2=A0 =C2=A0 =C2=A0A security discussion was recently given:
> http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> And a patch that I submitted awhile back was brought up. =C2=A0Appare=
ntly some of
> their testing revealed that they were able to force a buffer fragment=
 in e1000
> in which the trailing fragment was greater than 4 bytes. =C2=A0As a r=
esult the
> fragment check I introduced failed to detect the fragement and a part=
ial invalid
> frame was passed up into the network stack. =C2=A0I've written this p=
atch to correct
> it. =C2=A0I'm in the process of testing it now, but it makes good log=
ical sense to
> me. =C2=A0Effectively it maintains a per-adapter state variable which=
 detects a
> non-EOP frame, and discards it and subsequent non-EOP frames leading =
up to _and_
> _including_ the next positive-EOP frame (as it is by definition the l=
ast
> fragment). =C2=A0This should prevent any and all partial frames from =
entering the
> network stack from e1000
>
> Regards
> Neil
>
>
> =C2=A0e1000.h =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A03 ++-
> =C2=A0e1000_main.c | =C2=A0 14 ++++++++++++--
> =C2=A02 files changed, 14 insertions(+), 3 deletions(-)
>
>

Thanks Neil.  I have add the patch to my queue of patches.

--=20
Cheers,
Jeff
