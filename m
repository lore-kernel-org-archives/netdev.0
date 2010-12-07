From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: biosdevname v0.3.2
Date: Tue, 07 Dec 2010 18:41:22 +0000
Message-ID: <1291747282.21627.9.camel@bwh-desktop>
References: <20101206140649.GA13628@auslistsprd01.us.dell.com>
	 <1291745782.21627.6.camel@bwh-desktop>
	 <20101207181910.GA2643@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	"K, Narendra" <Narendra_K@Dell.com>,
	"Hargrave, Jordan" <Jordan_Hargrave@Dell.com>,
	"Rose, Charles" <Charles_Rose@Dell.com>,
	Colin Watson <cjwatson@ubuntu.com>
To: Matt Domsch <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101207181910.GA2643@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-12-07 at 12:19 -0600, Matt Domsch wrote:
> On Tue, Dec 07, 2010 at 06:16:22PM +0000, Ben Hutchings wrote:
> > It appears that 'unknown slot' is treated as a specific slot and all
> > devices with an unknown slot are given unique indices.  Perhaps this
> > doesn't matter in the end, since no name is generated when the slot is
> > unknown.
> 
> Yes on all counts.
>  
> > However, the 2 NIC ports do have their own indices (specified with the
> > dev_id attribute) and it should be possible to distinguish slots by
> > PCI/PCIe topology even though the name given won't correspond to any
> > markings on the motherboard.
> 
> Tell me more about the dev_id attribute.  I'm happy to use it, but I
> don't understand the rules around populating it.

As I understand it, dev_id is supposed to distinguish net devices
corresponding to multiple ports on a single network controller.
However, a value of 0 could mean either 'unspecified' or 'first port' so
you would have to verify that multiple net devices for the same slot
have unique dev_id values before taking them into account.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

