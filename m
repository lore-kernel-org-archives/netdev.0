From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH V2] New Xen netback implementation
Date: Mon, 30 Jan 2012 15:01:47 +0000
Message-ID: <1327935707.5553.27.camel@leeds.uk.xensource.com>
References: <1326808024-3744-1-git-send-email-wei.liu2@citrix.com>
	 <20120127192214.GA14437@phenom.dumpdata.com>
	 <1327844561.2911.5.camel@leeds.uk.xensource.com>
	 <20120129213746.GA7164@phenom.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"David Vrabel" <david.vrabel@citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:24356 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab2A3PBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 10:01:36 -0500
In-Reply-To: <20120129213746.GA7164@phenom.dumpdata.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-01-29 at 21:37 +0000, Konrad Rzeszutek Wilk wrote:
> Sure. I also did some testing with limiting the amount of CPUs and found
> that 'xl vcpu-set 0 N' make netback not work anymore :-( 
> > 

Any stack trace? Oops message? Did you increase the number of CPUs or
decrease the number?

I didn't pay much attention on the CPU hotplug path TBH. And the V3
series, which I just posted, has a completed different per-cpu scratch
space implementation, which takes care of CPU hotplug events.


Wei.
