From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Wed, 23 Apr 2008 11:07:04 +0100
Message-ID: <20080423100702.GS21637@solarflare.com>
References: <20080422160130.0b84959a@speedy> <20080423060018.GA3946@ff.dom.local> <20080423061538.GB3946@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:49030 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751513AbYDWKHK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 06:07:10 -0400
Content-Disposition: inline
In-Reply-To: <20080423061538.GB3946@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Apr 23, 2008 at 06:00:18AM +0000, Jarek Poplawski wrote:
> > On 23-04-2008 01:01, Stephen Hemminger wrote:
> > ...
> > >>>> First off, no hardware should ever do LRO on non-local packets. If the
> > >>>> hardware isn't smart enough to do this, I guess the bridge code to have
> > >>>> an API to turn it off. IP should also turn it off if ip_forwarding
> > >>>> is enabled on that device.
> > 
> > Could you explain this more? (I can't see any obvious reason why
> > forwarding between local networks should differ here from bridging?)
>
> ...and the second question: is only ip_forwarding flag checking right
> way to disable something destined for local packets?

"Non-local" here simply means destined for another host.  It doesn't
matter whether that host is on the same LAN or not.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
