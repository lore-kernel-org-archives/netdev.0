From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Wed, 23 Apr 2008 10:38:10 +0000
Message-ID: <20080423103809.GB3994@ff.dom.local>
References: <20080422160130.0b84959a@speedy> <20080423060018.GA3946@ff.dom.local> <20080423061538.GB3946@ff.dom.local> <20080423100702.GS21637@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:22184 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbYDWKfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 06:35:19 -0400
Received: by nf-out-0910.google.com with SMTP id g13so967089nfb.21
        for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 03:35:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080423100702.GS21637@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2008 at 11:07:04AM +0100, Ben Hutchings wrote:
> Jarek Poplawski wrote:
> > On Wed, Apr 23, 2008 at 06:00:18AM +0000, Jarek Poplawski wrote:
> > > On 23-04-2008 01:01, Stephen Hemminger wrote:
> > > ...
> > > >>>> First off, no hardware should ever do LRO on non-local packets. If the
> > > >>>> hardware isn't smart enough to do this, I guess the bridge code to have
> > > >>>> an API to turn it off. IP should also turn it off if ip_forwarding
> > > >>>> is enabled on that device.
> > > 
> > > Could you explain this more? (I can't see any obvious reason why
> > > forwarding between local networks should differ here from bridging?)
> >
> > ...and the second question: is only ip_forwarding flag checking right
> > way to disable something destined for local packets?
> 
> "Non-local" here simply means destined for another host.  It doesn't
> matter whether that host is on the same LAN or not.

Thanks for explanation! I'd still like to know why it's wrong, and
why we should turn this off on a device with ip_forwarding enabled
without checking how smart this hardware is?

Regards,
Jarek P.
