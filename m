From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: ethernet: stmmac: properly set PS bit in MII
 configurations during reset
Date: Sun, 25 Jun 2017 14:32:34 +0200
Message-ID: <20170625143234.358a8ae8@windsurf.home>
References: <1493286329-24448-1-git-send-email-thomas.petazzoni@free-electrons.com>
        <deea272a-f0a9-ad0b-4ad6-387723938314@st.com>
        <20170503143032.GA22106@Red>
        <49297ed2-84dc-3e9b-8f40-af915476a091@st.com>
        <20170508211230.58aeead9@free-electrons.com>
        <e8151650-aa51-6713-f10c-b3663763ff78@st.com>
        <20170510091817.58f4e843@free-electrons.com>
        <20170515162734.187845dc@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        <netdev@vger.kernel.org>, <stable@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170515162734.187845dc@free-electrons.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Giuseppe,

On Mon, 15 May 2017 16:27:34 +0200, Thomas Petazzoni wrote:

> On Wed, 10 May 2017 09:18:17 +0200, Thomas Petazzoni wrote:
> 
> > On Wed, 10 May 2017 09:03:12 +0200, Giuseppe CAVALLARO wrote:
> >   
> > > > Please, read again my patch and the description of the problem that I
> > > > have sent. But basically, any solution that does not allow to set the
> > > > PS bit between asserting the DMA reset bit and polling for it to clear
> > > > will not work for MII PHYs.      
> > > 
> > > yes your point was clear to me, I was just wondering if we could find an 
> > > easier way
> > > to solve it w/o changing the API, adding  the set_ps and propagating the 
> > > "interface"
> > > inside the DMA reset.
> > > 
> > > Maybe this could be fixed in the glue-logic in some way. Let me know 
> > > what do you think.    
> > 
> > Well, it's more up to you to tell me how you would like this be solved.
> > We figured out what the problem was, but I don't know well enough the
> > architecture of the driver to decide how the solution to this problem
> > should be designed. I made an initial simple proposal to show what is
> > needed, but I'm definitely open to suggestions.  
> 
> Do you have any suggestion on how to move forward with this?

Another kind ping on this topic. I really would like to have the
SPEAr600 network support work out of the box in mainline, which
currently isn't the case with an MII PHY.

I posted a patch that fixes the problem, see
https://patchwork.ozlabs.org/patch/755926/, but the feedback I got so
far does not give any direction on how to rework the patch to make it
acceptable. Would it be possible to get some more feedback?

Thanks a lot,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
