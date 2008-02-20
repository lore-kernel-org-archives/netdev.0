From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 20 Feb 2008 15:17:29 -0800
Message-ID: <1203549449.13495.140.camel@dell>
References: <47BB54C2.6090501@cybernetics.com>
 <20080220013824.GA5416@localdomain> <47BCB1E9.8020102@cybernetics.com>
 <20080220.150850.56732755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tonyb@cybernetics.com, mcarlson@broadcom.com,
	herbert@gondor.apana.org.au, netdev <netdev@vger.kernel.org>,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934868AbYBTXWi@vger.kernel.org>
In-Reply-To: <20080220.150850.56732755.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2008-02-20 at 15:08 -0800, David Miller wrote:
> From: Tony Battersby <tonyb@cybernetics.com>
> Date: Wed, 20 Feb 2008 18:04:09 -0500
> 
> > The following patch fixes the problem for me.  Do we want to accept this
> > patch and call it a day or continue investigating the source of the problem?
> > 
> > Patch applies to 2.6.24.2, but doesn't apply to 2.6.25-rc.  If everyone
> > agrees that this is the right solution, I will resubmit with a proper
> > subject line and description.
> 
> A chipset bug, if it even exists, should be worked around in the
> driver for that hardware.  We shouldn't make every other piece
> of hardware in the world suffer too.
> 
> 

Yes, we should workaround this in the TG3 driver once we understand what
the problem is and how to workaround it.  We are still looking through
the errata list to sort this out.  It looks like it is the starting DMA
address of the TX buffer that is causing the problem.
