From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Tue, 20 Oct 2009 17:44:59 +0200
Message-ID: <4ADDDAFB.5040600@gmail.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36572 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbZJTPpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 11:45:00 -0400
In-Reply-To: <1256052161-14156-1-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef a =E9crit :
> Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
> time stamp and window scale into per route entry feature options,
> laying the ground to future removal of the relevant global sysctls.
>=20
> You really only want to disable SACK, DSACK, time stamp or window
> scale if you've got a piece of broken networking equipment somewhere=20
> as a stop gap until you can bring a big enough hammer to deal with
> the broken network equipment. It doesn't make sense to "punish" the
> entire connections going through the machine to destinations not=20
> related to the broken equipment.
>=20
> This is doubly true when you're dealing with network containers
> used to isolate several virtual domains.
>=20
> Per route options implemented in free bits in the features route
> entry property, which in some cases were reserved by name for these
> options, so this does not inflate any structure and I expect that
> when the apropriate global sysctls will be removed the overall code
> base will be smaller.
>=20
> Tested on x86 using Qemu/KVM. =20
>=20
> Will send the matching patch to iproute2 if/when this is ACKed or
> if someone wants to test this.
>=20
> Patchset based on original work by Ori Finkelman and Yoni Amit=20
> from ComSleep Ltd.
>=20
> Gilad Ben-Yossef (8):
>   Only parse time stamp TCP option in time wait sock
>   Allow tcp_parse_options to consult dst entry
>   Infrastructure for querying route entry features
>   Add the no SACK route option feature
>   Allow disabling TCP timestamp options per route
>   Allow to turn off TCP window scale opt per route
>   Allow disabling of DSACK TCP option per route
>   Document future removal of sysctl_tcp_* options
>=20

Interesting... But you should give numbers to your patches so that we k=
now their order

You could also do the ECN part for consistency (ie RTAX_FEATURE_ECN -> =
RTAX_FEATURE_NO_ECN)

And please post iproute2 patches as well :)

Thanks
