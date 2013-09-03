From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: VLAN HW accel, performance advantage?
Date: Tue, 3 Sep 2013 16:08:40 +0200
Message-ID: <OF0F246C2A.B5DC5CA4-ONC1257BDB.004CA4E6-C1257BDB.004DB31E@transmode.se>
References: <OF00E35E7C.7482EC01-ONC1257BDB.00314AD0-C1257BDB.0031F6D0@transmode.se> <1378216216.1545.1.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:63772 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694Ab3ICOIn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Sep 2013 10:08:43 -0400
In-Reply-To: <1378216216.1545.1.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> wrote on 2013/09/03 15:50:16:
> 
> On Tue, 2013-09-03 at 11:05 +0200, Joakim Tjernlund wrote:
> > I am considering impl. VLAN HW acceleration in Freescales ucc_geth 
driver 
> > to improve
> > performance, primarily for bridged interfaces.
> >  I am hoping the community has some insights as to what performance 
gains 
> > one
> > could expect?
> 
> At the moment you need to do VLAN RX offload (or fake it in software) to
> take advantage of GRO for VLAN-encapsulated packets.  Other than that, I
> don't think it makes a lot of difference in most situations.
> 
> Ben.

Thanks Ben

I figured one would avoid some memmoves if the tag was extracted and as we 
got
a fairly slow CPU (some 300 MHZ MPC 8321) one should gain some performance 
but not so then.

I am not familiar with GRO( and its friends) but I am guessing it won't 
help
the bridge function or reduce stress from packet storms?

 Jocke
 
