From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
Date: Fri, 15 Oct 2004 12:48:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410151948.i9FJmo39006757@guinness.s2io.com>
References: <41701B3C.8020006@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Raghavendra Koushik'" <raghavendra.koushik@s2io.com>,
        "'Chris Leech'" <chris.leech@gmail.com>, <ravinandan.arakali@s2io.com>,
        "'Francois Romieu'" <romieu@fr.zoreil.com>, <netdev@oss.sgi.com>,
        <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <41701B3C.8020006@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OK, we will debug and try to fix this. 
Leonid

> -----Original Message-----
> From: Jeff Garzik [mailto:jgarzik@pobox.com] 
> Sent: Friday, October 15, 2004 11:47 AM
> To: Leonid Grossman
> Cc: 'Raghavendra Koushik'; 'Chris Leech'; 
> ravinandan.arakali@s2io.com; 'Francois Romieu'; 
> netdev@oss.sgi.com; rapuru.sriram@s2io.com
> Subject: Re: [PATCH 2.6.9-rc2 8/8] S2io: two buffer mode
> 
> Leonid Grossman wrote:
> >  "fragmented SKB on Rx" is an old problem - we tried to 
> deploy 2 and 5 
> > buffer Xframe modes before and it did not work in Linux.
> > Is anyone aware of any network driver that successfully uses 
> > fragmented SKBs?
> 
> Raghavendra Koushik wrote:
> > I did try fragmented SKB on Rx but it didn't seem to work. 
> If any one 
> > can give me some pointers on how to get this working, I would 
> > implement 2Buff mode using this method and avoid a copy in 
> fast path.
> 
> 
> 
> My suggestion would be to investigate why fragmented SKBs 
> don't work ;-)
> 
> The source code is all there, debug away...
> 
> If S2IO can fix this, a lot of people will benefit.
> 
> 	Jeff
> 
> 
