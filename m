From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: hardware time stamps + existing time stamp usage
Date: Mon, 20 Oct 2008 09:35:14 +0200
Message-ID: <1224488114.17450.224.camel@ecld0pohly>
References: <1224253423.17450.211.camel@ecld0pohly>
	 <48F96DD6.5060904@cosmosbay.com> <48F99286.9050706@hartkopp.net>
	 <48F9A43A.7070801@cosmosbay.com>  <48F9B610.2090504@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Ingo Oeser <netdev@axxeo.de>, Andi Kleen <ak@linux.intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28335 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbYJTHhT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2008 03:37:19 -0400
In-Reply-To: <48F9B610.2090504@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-10-18 at 04:10 -0600, Oliver Hartkopp wrote:
> Eric Dumazet wrote:
> > Oliver Hartkopp a =E9crit :
> >> Eric Dumazet wrote:
> >> If so i would tend to fill both (system time and hw timestamp) on
> >> driver level into the skb and then decide on socket level what to
> >> push into user space as you suggested above.
> >
> > Well, this would enlarge skb structure by 8 bytes, since you cannot=
 use
> > same tstamp location to fille both 8 bytes values.
> > This is probably the easy way, but very expensive...
>=20
> IMHO this is the only way to fulfill the given requirements.
> Maybe we should introduce a new kernel config option for hw tstamps t=
hen ...

The last time this topic was discussed the initial proposal also was to
add another time stamp, pretty much for the same reasons. This approach
was discarded because enlarging a common structure like skb for rather
obscure ("Objection, your honor!" - "Rejected.") use cases is not
acceptable. A config option doesn't help much either because to be
useful for distribution users, it would have to be on by default.

--=20
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.

