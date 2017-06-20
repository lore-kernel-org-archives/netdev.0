From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH] liquidio: stop using huge static buffer, save 4096k in
 .data
Date: Tue, 20 Jun 2017 13:51:25 -0700
Message-ID: <20170620205125.GA1364@felix-thinkpad.cavium.com>
References: <20170619195052.13176-1-dvlasenk@redhat.com>
 <20170620.152142.1443468587541525646.davem@davemloft.net>
 <MWHPR07MB29434F09FBC054D2E0310D6FF3C50@MWHPR07MB2943.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        "dvlasenk@redhat.com" <dvlasenk@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kanneganti, Prasad" <Prasad.Kanneganti@cavium.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Derek Chickles <Derek.Chickles@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <MWHPR07MB29434F09FBC054D2E0310D6FF3C50@MWHPR07MB2943.namprd07.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Derek Chickles <Derek.Chickles@cavium.com>
Date: Tue, 20 Jun 2017 13:15:34 -0700

> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: Tuesday, June 20, 2017 12:22 PM
> > 
> > From: Denys Vlasenko <dvlasenk@redhat.com>
> > Date: Mon, 19 Jun 2017 21:50:52 +0200
> > 
> > > Only compile-tested - I don't have the hardware.
> > >
> > > From code inspection, octeon_pci_write_core_mem() appears to be safe wrt
> > > unaligned source. In any case, u8 fbuf[] was not guaranteed to be aligned
> > > anyway.
> > >
> > > Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> > 
> > Looks good to me but I'll let one of the liquidio guys review this first
> > before I apply it.
> 
> Felix is going to try this out this week to confirm. Let's wait for his ack.

This patch works.  I tested it with a LiquidIO II adapter.

ACK
