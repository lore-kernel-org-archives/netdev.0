From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 17:06:11 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32903C440EE@orsmsx414.amr.corp.intel.com>
References: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com><20071011.163737.36654032.davem@davemloft.net><470EB6D6.9020704@hp.com> <20071011.170244.32082446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>, <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28292 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754561AbXJLAGM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 20:06:12 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071011.170244.32082446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 11 Oct 2007 16:50:46 -0700
> 
> > For just messing about, might it be possible to tweak the socket 
> > buffer sizes and tcp_tso_win_divisor to kludge things for a short 
> > while?  Couldn't ship that way certainly, but assuming 
> Peter's going 
> > to get his broken hardware fixed it might let him limp 
> along until then.
> 
> TCP dynamically grows the socket buffer sizes unless the 
> application explicitly sets them via setsockopt() and the 
> limits imposed in those cases are controlled by 
> tcp_{,r,w}mem[] sysctls.  Decreasing those will kill 
> performance exactly for the cases this person cares about.
> 
> No, the only way to deal with this is to GSO segment incoming 
> frames inside of the driver when they exceed the HW limits.

Thanks Dave and Rick.  I'll mess with this and make my driver happy
again.

Cheers,
-PJ Waskiewicz
