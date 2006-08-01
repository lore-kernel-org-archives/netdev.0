From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: Re[4]: e1000 speed/duplex error
Date: Tue, 1 Aug 2006 05:34:43 -0700
Message-ID: <9929d2390608010534x54324569ja70b1fcbdc23c097@mail.gmail.com>
References: <1301563340.20060801141827@mail.ru>
	 <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com>
	 <793732866.20060801153230@mail.ru>
	 <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com>
	 <911206621.20060801162006@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:8059 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1751508AbWHAMep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 08:34:45 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1278943ugc
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2006 05:34:44 -0700 (PDT)
To: a1 <a1k@mail.ru>
In-Reply-To: <911206621.20060801162006@mail.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/1/06, a1 <a1k@mail.ru> wrote:
> Hi, Jeff.
>
>
> JK> OPTION 2: Turn auto-negotiate on the e1000 card and tell it to only
> JK> advertise 100 Full Duplex.  This will allow negotiation between the
> JK> two lnk partners and the e1000 will advertise that it is only able to
> JK> do 100 Full duplex.
>
> Is there any way i could do this with ethtool? It only allows force
> spd/dplx , but not set it for advertising...

Not currently.  That would be a nice feature though... :)

>
> If i do as follows other side reports 1000/FD:
>
> ethtool -s eth0 speed 100 duplex full autoneg on
>

Which is what I would expect.  I have to step away for a bit, but if
no one responds with how to load the driver with auto-negotiate
advertising only 100 Full Duplex, I will do so when I return.

-- 
Cheers,
Jeff
