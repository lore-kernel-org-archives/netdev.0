From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 11:42:56 -0700
Message-ID: <451AC630.2030509@intel.com>
References: <20060926145113.7a6791c8@freekitty> <4519A1D6.1050802@pobox.com> <20060926150947.3d538547@freekitty> <451A7603.1030204@roinet.com> <451AAFFE.2020607@hp.com> <451AB9CB.6010906@intel.com> <451ABB73.1050606@hp.com> <Pine.LNX.4.64N.0609271858440.7657@blysk.ds.pg.gda.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, David Acker <dacker@roinet.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59322 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S965145AbWI0Soq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 14:44:46 -0400
To: "Maciej W. Rozycki" <macro@linux-mips.org>
In-Reply-To: <Pine.LNX.4.64N.0609271858440.7657@blysk.ds.pg.gda.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maciej W. Rozycki wrote:
> On Wed, 27 Sep 2006, Rick Jones wrote:
> 
>>> Another scenario: forcing the NIC to negotiate only full-duplex speeds. Not
>>> only fun if you try it against a hub, but possibly useful.
> [...]
>> I'm just worried (as in Fear Uncertainty and Doubt) that having people set the
>> allowed things to negotiate isn't really any more robust than stright-up
>> hardcodes and perpetuates the (IMO) myth that one shouldn't autoneg on general
>> principle.
> 
>  Older equipment, which may still be in use here and there, allowed 
> full-duplex operation, but no auto-negotiation.  The duplex setting was 
> either fixed or selectable in a system-specific manner.  In such a case 
> you certainly want your modern other end to be forced to full-duplex, but 
> still let it detect the link speed, so that you do not have to do 
> reconfiguration whenever you move a link between a 10base-T and a 
> 100base-Tx port.

in this case the new addition to ethtool will not help as it only changes the 
modes that the NIC will advertise. In this specific case you will need to turn 
of advertising/autonegotiation and force a speed/duplex pair anyway.

Advertising all half-duplex modes to a partner that does not do autonegotiation 
is (by spec I think) an unsupported configuration (i.e. undetermined behaviour).

That's nothing new.

Auke
