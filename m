From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Netem] [Fwd:  [PATCH 2.6.18 0/2] LARTC: trace control for
 netem]
Date: Tue, 13 Feb 2007 16:16:02 -0800
Message-ID: <20070213161602.16607203@freekitty>
References: <45827B5C.3090402@tik.ee.ethz.ch>
	<45CA1C26.1080405@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@VGER.KERNEL.ORG, netem@linux-foundation.org
To: Rainer Baumann <baumann@tik.ee.ethz.ch>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <45CA1C26.1080405@tik.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 07 Feb 2007 19:36:22 +0100
Rainer Baumann <baumann@tik.ee.ethz.ch> wrote:

> Hi Stephen
> 
> I just wanted to ask you, if you already had time to test our trace
> extension for netem as discussed on the 13th of December.
> 
> Cheers
> Rainer
> 
> Rainer Baumann wrote:
> > Hi Stephen
> >
> > As discussed yesterday, here our patches to integrate trace control into netem
> >
> >
> >
> > Trace Control for Netem: Emulate network properties such as long range dependency and self-similarity of cross-traffic.
> >
> > A new option (trace) has been added to the netem command. If the trace option is used, the values for packet delay etc. are read from a pregenerated trace file, afterwards the packets are processed by the normal netem functions. The packet action values are readout from the trace file in user space and sent to kernel space via configfs.
> >
> >
> 

I looked at it some more, and want to go in and clean the configuration and buffer interface
slightly before inclusion. Once it is in I get stuck with the ABI so don't want to do something
wrong.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
