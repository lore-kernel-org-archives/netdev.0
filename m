From: "Raghavendra Koushik" <raghavendra.koushik@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Fri, 15 Oct 2004 16:14:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410152314.i9FNEs39016702@guinness.s2io.com>
References: <41701B3C.8020006@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'Chris Leech'" <chris.leech@gmail.com>, <ravinandan.arakali@s2io.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>, <netdev@oss.sgi.com>,
        <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>,
        "'Leonid Grossman'" <leonid.grossman@s2io.com>
In-Reply-To: <41701B3C.8020006@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,
 In this submission I'll use copy for 2Buff mode, but continue to debug the
fragmented skb Rx. If we do get it working sometime, I'll submit another
patch to update the driver. Is this Ok?

- Koushik

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com]
> Sent: Friday, October 15, 2004 11:47 AM
> To: Leonid Grossman
> Cc: 'Raghavendra Koushik'; 'Chris Leech'; ravinandan.arakali@s2io.com;
> 'Francois Romieu'; netdev@oss.sgi.com; rapuru.sriram@s2io.com
> Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
> 
> Leonid Grossman wrote:
> >  "fragmented SKB on Rx" is an old problem - we tried to deploy 2 and 5
> > buffer Xframe modes before and it did not work in Linux.
> > Is anyone aware of any network driver that successfully uses fragmented
> > SKBs?
> 
> Raghavendra Koushik wrote:
> > I did try fragmented SKB on Rx but it didn't seem to work. If any one
> can
> > give me some pointers on how to get this working, I would implement
> 2Buff
> > mode using this method and avoid a copy in fast path.
> 
> 
> 
> My suggestion would be to investigate why fragmented SKBs don't work ;-)
> 
> The source code is all there, debug away...
> 
> If S2IO can fix this, a lot of people will benefit.
> 
> 	Jeff
