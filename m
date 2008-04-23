From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: LRO/GSO interaction when packets are forwarded
Date: Wed, 23 Apr 2008 06:15:38 +0000
Message-ID: <20080423061538.GB3946@ff.dom.local>
References: <20080422160130.0b84959a@speedy> <20080423060018.GA3946@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.184]:2278 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760252AbYDWGMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 02:12:49 -0400
Received: by fk-out-0910.google.com with SMTP id 19so3589412fkr.5
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2008 23:12:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080423060018.GA3946@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2008 at 06:00:18AM +0000, Jarek Poplawski wrote:
> On 23-04-2008 01:01, Stephen Hemminger wrote:
> ...
> >>>> First off, no hardware should ever do LRO on non-local packets. If the
> >>>> hardware isn't smart enough to do this, I guess the bridge code to have
> >>>> an API to turn it off. IP should also turn it off if ip_forwarding
> >>>> is enabled on that device.
> 
> Could you explain this more? (I can't see any obvious reason why
> forwarding between local networks should differ here from bridging?)

...and the second question: is only ip_forwarding flag checking right
way to disable something destined for local packets?
 
Jarek P.
