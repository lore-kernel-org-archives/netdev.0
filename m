From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Tue, 20 Oct 2009 18:11:30 +0200
Message-ID: <4ADDE132.3010408@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com> <4ADDDAFB.5040600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:60342 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbZJTQLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 12:11:30 -0400
In-Reply-To: <4ADDDAFB.5040600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Gilad Ben-Yossef a =E9crit :
>  =20
>> Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
>> time stamp and window scale into per route entry feature options,
>> laying the ground to future removal of the relevant global sysctls.
>>
>> ...
> Interesting... But you should give numbers to your patches so that we=
 know their order
>  =20
Will do.
> You could also do the ECN part for consistency (ie RTAX_FEATURE_ECN -=
> RTAX_FEATURE_NO_ECN)
>  =20
That and  sysctl_tcp_mtu_probing are on my todo list, assuming the=20
general direction is accepted, of course.

Specifically, I couldn't understand why sysctl_tcp_ecn is documented to=
=20
be a boolean value, but is initialized to 2 and queried with if=20
(sysctl_tcp_ecn =3D=3D 1) so I decided to let it be until I figure it o=
ut...=20
;-)
> And please post iproute2 patches as well :)
>  =20
Will do. Note that the patch I have still has an ugly bit that needs=20
addressing - it sets the features by name, but right now only displays=20
numeric values to the, for "show". This of course will be fixed, but it=
=20
does work for testing.

Thanks,
Gilad

--=20
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
=46ax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxolog=
y.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

