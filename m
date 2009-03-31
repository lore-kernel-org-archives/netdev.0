From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 00/14] Add common OF device tree support for MDIO busses
Date: Tue, 31 Mar 2009 16:19:42 -0600
Message-ID: <fa686aa40903311519m3108c697v52180d192975a3b1@mail.gmail.com>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
	 <20090331.145738.36845509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, olof@lixom.net,
	afleming@freescale.com, galak@kernel.crashing.org,
	avorontsov@ru.mvista.com, Joakim.Tjernlund@transmode.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:22324 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757419AbZCaWTo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 18:19:44 -0400
Received: by yw-out-2324.google.com with SMTP id 5so2648051ywb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 15:19:42 -0700 (PDT)
In-Reply-To: <20090331.145738.36845509.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 31, 2009 at 3:57 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Tue, 31 Mar 2009 02:26:43 -0600
>
>> David, as I mentioned below, I'd really like to get the core changes
>> (1, 4, 5 =A06) merged into 2.6.30 (assuming Andy confirms they are o=
kay).
>
> No, sorry.
>
> We could have worked out the interdependencies before the merge windo=
w
> openned up. =A0There is no reason this could not have sat in at least
> somebody's tree before the merge window started.

It's been out there on the list since before the merge window, getting
tested by more than just me.  This is not series which has simply
dropped out of thin air.  I've been working hard to address issues
reported by others (Thanks Olof!) and to keep it building and applying
cleanly to the top of tree.

> It therefore didn't get any -next exposure, so it's unreasonable to
> merge this stuff now.

Since when has sitting in a -next tree been a requirement for merging
when the series has been kept up to date and tested?  I purposefully
kept it out of -next to ensure that when it was applied for real to a
-next tree it would be as complete, bug free, and bisectable as
possible since once it hits a signed-off -next branch the individual
commit cannot be modified.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
