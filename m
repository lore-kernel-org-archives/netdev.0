From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bridge] [PATCH] macvlan: add tap device backend
Date: Fri, 7 Aug 2009 12:35:54 -0700
Message-ID: <20090807123554.7c2bc27c@nehalam>
References: <0199E0D51A61344794750DC57738F58E6D6A6CD7F6@GVW1118EXC.americas.hpqcorp.net>
	<004f01ca1792$b24a7a90$16df6fb0$@edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <drobbins@funtoo.org>,
	"'Paul Congdon \(UC Davis\)'" <ptcongdon@ucdavis.edu>,
	"'Fischer, Anna'" <anna.fischer@hp.com>,
	"'Arnd Bergmann'" <arnd@arndb.de>, <herbert@gondor.apana.org.au>,
	<mst@redhat.com>, <netdev@vger.kernel.org>,
	<bridge@lists.linux-foundation.org>,
	<linux-kernel@vger.kernel.org>, <ogerlitz@voltaire.com>,
	<evb@yahoogroups.com>, <davem@davemloft.net>
To: "Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52731 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933123AbZHGTgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2009 15:36:02 -0400
In-Reply-To: <004f01ca1792$b24a7a90$16df6fb0$@edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Aug 2009 12:10:07 -0700
"Paul Congdon \(UC Davis\)" <ptcongdon@ucdavis.edu> wrote:

> Responding to Daniel's questions...
> 
> > I have some general questions about the intended use and benefits of 
> > VEPA, from an IT perspective:
> > 
> > In which virtual machine setups and technologies do you forsee this 
> > interface being used?
> 
> The benefit of VEPA is the coordination and unification with the external network switch.  So, in environments where you are needing/wanting your feature rich, wire speed, external network device (firewall/switch/IPS/content-filter) to provide consistent policy enforcement, and you want your VMs traffic to be subject to that enforcement, you will want their traffic directed externally.  Perhaps you have some VMs that are on a DMZ or clustering an application or implementing a multi-tier application where you would normally place a firewall in-between the tiers.

I do have to raise the point that Linux is perfectly capable of keeping up without
the need of an external switch.  Whether you want policy external or internal is
a architecture decision that should not be driven by mis-information about performance.
