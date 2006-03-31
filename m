From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [PATCH 1/9] [I/OAT] DMA memcpy subsystem
Date: Fri, 31 Mar 2006 10:26:33 +0200
Message-ID: <200603311026.33391.netdev@axxeo.de>
References: <20060329225505.25585.30392.stgit@gitlost.site> <c0a09e5c0603301036s4e9a63e5v476d89ff8ba37760@mail.gmail.com> <351C5BDA-D7E3-4257-B07E-ABDDCF254954@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Grover <andy.grover@gmail.com>,
	"Chris Leech" <christopher.leech@intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751274AbWCaI0x@vger.kernel.org>
To: Kumar Gala <galak@kernel.crashing.org>
In-Reply-To: <351C5BDA-D7E3-4257-B07E-ABDDCF254954@kernel.crashing.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kumar Gala wrote:
> On Mar 30, 2006, at 12:36 PM, Andrew Grover wrote:
> > Well....it's true they're useful for debugging but I would put them in
> > the category of system statistics that shouldn't go in debugfs. I
> > think they are like /proc/interrupts' interrupt counts or the TX/RX
> > stats reported by ifconfig.
> 
> Fair, but wouldn't it be better to have the association per client.
> 
> Maybe leave the one as a summary and have a dir per client with  
> similar stats that are for each client and add a per channel summary  
> at the top level as well.

Such level of detail really belongs to debugging, IMHO.

I think, it would suffer to say, how many channels are in use.
So you can answer the question, whether your customers are actually
using this experimental technology. 

If you want more, let them mount debugfs. 
If it becomes really important, we can revisit this later.

Thats the advantage of files under debugfs 
not being stable API in any way.

BTW: What is the actual frequency, at which such counters 
will be incremented?


Regards

Ingo Oeser
