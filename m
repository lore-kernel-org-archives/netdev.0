From: "Jeff Kirsher" <tarbal@gmail.com>
Subject: Re: e1000 speed/duplex error
Date: Tue, 1 Aug 2006 10:15:14 -0700
Message-ID: <9929d2390608011015h32c034bdt2b6bd89f4ade972e@mail.gmail.com>
References: <1301563340.20060801141827@mail.ru>
	 <9929d2390608010420t60bd44d7o4e522c6edc0a677e@mail.gmail.com>
	 <793732866.20060801153230@mail.ru>
	 <9929d2390608010445w4fd81b64g310ae90a423e1a7d@mail.gmail.com>
	 <911206621.20060801162006@mail.ru>
	 <9929d2390608010534x54324569ja70b1fcbdc23c097@mail.gmail.com>
	 <44CF66AD.1030901@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: a1 <a1k@mail.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.175]:6015 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750884AbWHARPQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 13:15:16 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1401313ugc
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2006 10:15:14 -0700 (PDT)
To: "Auke Kok" <auke-jan.h.kok@intel.com>
In-Reply-To: <44CF66AD.1030901@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/1/06, Auke Kok <auke-jan.h.kok@intel.com> wrote:
> Jeff Kirsher wrote:
> > On 8/1/06, a1 <a1k@mail.ru> wrote:
> >> Hi, Jeff.
> >>
> >>
> >> JK> OPTION 2: Turn auto-negotiate on the e1000 card and tell it to only
> >> JK> advertise 100 Full Duplex.  This will allow negotiation between the
> >> JK> two lnk partners and the e1000 will advertise that it is only able to
> >> JK> do 100 Full duplex.
> >>
> >> Is there any way i could do this with ethtool? It only allows force
> >> spd/dplx , but not set it for advertising...
> >
> > Not currently.  That would be a nice feature though... :)
> >
> >>
> >> If i do as follows other side reports 1000/FD:
> >>
> >> ethtool -s eth0 speed 100 duplex full autoneg on
> >>
> >
> > Which is what I would expect.  I have to step away for a bit, but if
> > no one responds with how to load the driver with auto-negotiate
> > advertising only 100 Full Duplex, I will do so when I return.
>
> Here's that part of the driver documentation:
>
> $ modprobe e1000 AutoNeg=0x08
> e1000: 0000:00:00.0: e1000_validate_option: AutoNeg advertising 100/FD
>
>
>   99 /* Auto-negotiation Advertisement Override
> 100  *
> 101  * Valid Range: 0x01-0x0F, 0x20-0x2F (copper); 0x20 (fiber)
> 102  *
> 103  * The AutoNeg value is a bit mask describing which speed and duplex
> 104  * combinations should be advertised during auto-negotiation.
> 105  * The supported speed and duplex modes are listed below
> 106  *
> 107  * Bit           7     6     5      4      3     2     1      0
> 108  * Speed (Mbps)  N/A   N/A   1000   N/A    100   100   10     10
> 109  * Duplex                    Full          Full  Half  Full   Half
> 110  *
> 111  * Default Value: 0x2F (copper); 0x20 (fiber)
> 112  */
>
> hth,
>
> Auke
>
Thanks Auke.  I got tied up longer than expected.

-- 
Cheers,
Jeff
