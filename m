From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: add wake-on-lan support via magic packet
Date: Tue, 16 May 2017 13:01:48 +0200
Message-ID: <20170516110145.GA27247@verge.net.au>
References: <20170511222735.10706-1-niklas.soderlund+renesas@ragnatech.se>
 <CAMuHMdUXqWJMh7syd3muMs8v9wx5bJNRj_3+xEAXTQTfAv0BFA@mail.gmail.com>
 <20170512125853.GH31437@bigcity.dyn.berto.se>
 <20170512143242.GA13939@bigcity.dyn.berto.se>
 <CAMuHMdU+uiiZfh5u+tL_bVJinhP-c0_iF4ZQh8=9NHN+aqUs=Q@mail.gmail.com>
 <20170512211222.GI31437@bigcity.dyn.berto.se>
 <CAMuHMdWZ8XLX0Zu0D54Ex+3RaFNm_fJyFQvyo+qz10HpB2nGqQ@mail.gmail.com>
 <20170516090214.GA30768@bigcity.dyn.berto.se>
 <CAMuHMdVkitTgVmUrPu5+z2JwnwHop4bJ5anMq1SmCeFfV=OxQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Niklas =?utf-8?Q?S=C3=B6derlund?= <niklas.soderlund@ragnatech.se>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMuHMdVkitTgVmUrPu5+z2JwnwHop4bJ5anMq1SmCeFfV=OxQg@mail.gmail.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 11:07:34AM +0200, Geert Uytterhoeven wrote:
> Hi Niklas,
> 
> On Tue, May 16, 2017 at 11:02 AM, Niklas Söderlund
> <niklas.soderlund@ragnatech.se> wrote:
> >> > Whit all this being said I still like to withdraw this patch as I found
> >> > another fault with it, ravb_wol_restore() will unconditionally be called
> >> > while ravb_wol_setup() will only be called if netif_running(ndev). This
> >> > is en easy fix and I will send out a v2 once we figure out what to do
> >> > about the clock.
> >>
> >> The clock issue is external to the ravb driver. If it works with
> >> s2idle, it should
> >> be OK.
> >
> > Do you think it's a good idea to move ahead with a v2 of the ravb WoL
> > patch to fix the unrelated issue and aim for it to be picked up prior to
> > suspend/resume support is added to the CPG/MSSR?
> 
> Sure.
> 
> It can still be used on R-Car Gen2, where we're not s*d by mandatory PSCI.

Is there some way for - e.g. the driver - to not enable WoL on Gen3 SoCs
until the clock issues is sorted out? I'm quite happy to enable features
where they work; not so much where they don't.
