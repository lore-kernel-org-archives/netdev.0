From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Mon, 14 Nov 2011 22:37:49 +0100
Message-ID: <20111114213749.GB2250@minipsycho>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
 <20111113.160951.1905657808657009542.davem@davemloft.net>
 <20111114173157.GE20605@gospo.rdu.redhat.com>
 <1321294672.2719.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, benjamin.poirier@gmail.com, jzupka@redhat.com,
	ivecera@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754847Ab1KNViB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 16:38:01 -0500
Content-Disposition: inline
In-Reply-To: <1321294672.2719.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 14, 2011 at 07:17:52PM CET, eric.dumazet@gmail.com wrote:
>Le lundi 14 novembre 2011 =E0 12:31 -0500, Andy Gospodarek a =E9crit :
>
>> I'm a bit surprised by this.  Not only is this new function currentl=
y
>> difficult to setup (it took me over an hour to go from a a fresh F16
>> install to one that had all the necessary libraries and tools to eve=
n
>> configure a team device for the first time), but I was able to cause=
 an
>> Oops with v8 in only a few minutes of testing.
>>=20
>> I have no problem with this functionality as an add-on and possibly
>> future replacement to some of what currently exists with bonding, bu=
t it
>> seems like what is included in the initial support should should:
>>=20
>> 1. Not panic easily.
>> 2. Have userspace bits in place to actually test all the proposed ke=
rnel
>> code.  (Jiri admits there is no way to verify the active-backup code=
).
>> 3. Have some known, published test results.
>>=20
>> I hope Jiri will reconsider having a separate team tree for the next=
 few
>> weeks or months until these issues are worked out.  I think the hard
>> work will pay off and it is close to being ready; it just doesn't se=
em
>> like it is right now.
>>=20
>
>Its marked EXPERIMENTAL, so probably some changes are expected before
>production mode :)

Exactly. The primary goal was to get this broader audience so people
use this and find bugs, like you did Andy :)
>
>
>
