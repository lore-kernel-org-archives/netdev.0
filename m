From: kuznet@ms2.inr.ac.ru
Subject: Re: PATCH Re: udp weirdness
Date: Thu, 3 Oct 2002 20:29:59 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210031629.UAA30047@sex.inr.ac.ru>
References: <20021003155841.GF601@hookipa>
Mime-Version: 1.0
Cc: greearb@candelatech.com, Eric.Lemoine@ens-lyon.fr,
   cfriesen@nortelnetworks.com, hadi@cyberus.CA, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric.Lemoine@ens-lyon.fr (Eric Lemoine)
In-Reply-To: <20021003155841.GF601@hookipa> from "Eric Lemoine" at Oct 3, 2 05:58:41 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > >Would you mind explaining a bit more why apps will lockup if we block
> > >after select() succeeded. Or anyone?

Because queue overflow is persistant condition. Do you want your routing
daemon went to coma when sending an update to dead ppp link?

But, actually, it is simply required by standards. No blocking after
select success is definition of select, in fact.

Alexey
