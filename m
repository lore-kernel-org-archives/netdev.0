From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 0/2] igb: drop stats due to OS cannot keep up
Date: Mon, 18 May 2009 00:16:50 -0700
Message-ID: <9929d2390905180016h4cf065fex51a6b6e061b41792@mail.gmail.com>
References: <1241703346.18487.22.camel@localhost.localdomain>
	 <9929d2390905141543g6f5adc32ndf65870bd49d83ea@mail.gmail.com>
	 <1242373277.8675.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f214.google.com ([209.85.217.214]:43349 "EHLO
	mail-gx0-f214.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755627AbZERHQt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 03:16:49 -0400
Received: by gxk10 with SMTP id 10so5983717gxk.13
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 00:16:50 -0700 (PDT)
In-Reply-To: <1242373277.8675.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2009 at 12:41 AM, Jesper Dangaard Brouer <hawk@comx.dk>=
 wrote:
> On Thu, 2009-05-14 at 15:43 -0700, Jeff Kirsher wrote:
>> Jesper - I have pulled in your patches, and made the necessary
>> modifications based on Mitch's comments. =C2=A0Right now, they are i=
n
>> testing and I should be pushing them to Dave in the next couple of
>> days.
>
> Sounds great! :-)
>
> Do you or e1000-devel have a public git tree?
> So I can work off that next time I have some changes, thus it would b=
e
> easier for you to merge in... (this time around I rebased my changes
> each time some of you igb changes got into daveM's net-next-2.6 tree)
>
> Cheers
> --
> Med venlig hilsen / Best regards
> =C2=A0Jesper Brouer
> =C2=A0ComX Networks A/S
> =C2=A0Linux Network developer
> =C2=A0Cand. Scient Datalog / MSc.
> =C2=A0Author of http://adsl-optimizer.dk
> =C2=A0LinkedIn: http://www.linkedin.com/in/brouer

No we do not have a public git tree, but do not worry about it.  Feel
free to send patches, and I can work through most of the issues if any
arise.  So no worries there...

Regarding your patches, during testing we saw a significant difference
in the stats reported by ifconfig versus the stats reported by
ethtool.  Reason being that ethtool stats do not take into account the
RQDPC numbers.  I have been looking at fixing that in the patches, so
while all the testing looks good (except for the difference in
numbers) the patches will be delayed a day or so, while I fix the
ethtool reporting of RQDPC.

--=20
Cheers,
Jeff
