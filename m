From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: Re: [RFC PATCH 00/17] virtual-bus
Date: Mon, 20 Apr 2009 12:02:54 -0600
Message-ID: <1240250574.26773.30.camel@lappy>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>
	 <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com>
	 <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com>
	 <20090401170103.GU11935@one.firstfloor.org>
	 <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com>
	 <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com>
	 <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com>
	 <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com>
	 <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com>
	 <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com>
	 <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com>
	 <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws>
	 <49D4E583.4080505@redhat.com>  <49D5018E.4040801@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Avi Kivity <avi@redhat.com>, Gregory Haskins <ghaskins@novell.com>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D5018E.4040801@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-04-02 at 13:18 -0500, Anthony Liguori wrote:
> Avi Kivity wrote:
> > Anthony Liguori wrote:
> >>> I don't think we even need that to end this debate.  I'm convinced 
> >>> we have a bug somewhere.  Even disabling TX mitigation, I see a ping 
> >>> latency of around 300ns whereas it's only 50ns on the host.  This 
> >>> defies logic so I'm now looking to isolate why that is.
> >>
> >> I'm down to 90us.  Obviously, s/ns/us/g above.  The exec.c changes 
> >> were the big winner... I hate qemu sometimes.
> 
> Anyway, if we're able to send this many packets, I suspect we'll be able 
> to also handle much higher throughputs without TX mitigation so that's 
> what I'm going to look at now.

Anthony,

Any news on this?  I'm anxious to see virtio-net performance on par with
the virtual-bus results.  Thanks,

Alex

