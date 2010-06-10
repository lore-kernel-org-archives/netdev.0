From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: no reassembly for outgoing packets on RAW socket
Date: Thu, 10 Jun 2010 08:57:02 +0200
Message-ID: <20100610065702.GB1915@jolsa.lab.eng.brq.redhat.com>
References: <20100604112708.GA1958@jolsa.lab.eng.brq.redhat.com>
 <4C08EB85.3050900@trash.net>
 <20100607145558.GA1939@jolsa.lab.eng.brq.redhat.com>
 <4C0FA24A.7060907@trash.net>
 <alpine.LSU.2.01.1006091713260.30265@obet.zrqbmnf.qr>
 <4C0FB068.9090700@trash.net>
 <alpine.LSU.2.01.1006091719010.30265@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.01.1006091719010.30265@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 09, 2010 at 05:20:37PM +0200, Jan Engelhardt wrote:
> 
> On Wednesday 2010-06-09 17:16, Patrick McHardy wrote:
> >Jan Engelhardt wrote:
> >> On Wednesday 2010-06-09 16:16, Patrick McHardy wrote:
> >>>>> You could use the NOTRACK target to bypass connection tracking.
> >>>>>         
> >>>> I tried the NOTRACK target, but the packet is still going
> >>>> throught reassembly, because the RAW filter has lower priority
> >>>> then the connection track defragmentation..
> >>>
> >>> Right.
> >>
> >> Blech. That reminds me of
> >> http://marc.info/?l=netfilter-devel&m=126581823826735&w=2
> >
> >We already fixed that.
> 
> I know, and I posted it for the understanding of the OP
> as to why RAW is after DEFRAG.

thanks, it's helpful
jirka
