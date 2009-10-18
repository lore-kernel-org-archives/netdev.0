From: Harald Welte <laforge@gnumonks.org>
Subject: Re: PF_RING: Include in main line kernel?
Date: Sun, 18 Oct 2009 14:50:14 +0200
Message-ID: <20091018125014.GH27747@prithivi.gnumonks.org>
References: <a07586b0910140733s1976cd05u39286de42d9fac23@mail.gmail.com>
 <200910141319.43884.bcook@bpointsys.com>
 <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brent Cook <bcook@bpointsys.com>,
	Brad Doctor <brad.doctor@gmail.com>, netdev@vger.kernel.org
To: Luca Deri <deri@ntop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:53883 "EHLO
	ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbZJRM4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 08:56:31 -0400
Content-Disposition: inline
In-Reply-To: <903D7FEC-34E8-4F70-ABC0-E56A3A5FBBE6@ntop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2009 at 09:54:26PM +0200, Luca Deri wrote:
> Brent
> contrary to other socket types, PF_RING allows
> - packets to be filtered using both BPF and ACL-like filters
> - parsing information is returned as metadata with the packet (i.e.
> you don't have to parse the packet again as it happens with BPF)
> - ACL-like filters allows you to specify advanced features such as
> port ranges or packet payload match

So it seems there is some added features over the existing functionality, plus
probably increased performance mainly to hooking earlier in the packet receive
flow.

What would normally be done is to try to make incremental changes
to the existing code and extend their features/performacne, rather than
adding something relatively similar alternative.

> I agree with you that PF_RING has some overlaps with PACKET_RX/
> TX_RING, but the main idea behind PF_RING is not just to accelerate
> packet capture. For instance in PF_RING you can have actions
> attached to rules, or extend PF_RING filtering/packet handling by
> means of plugins.

Is this in the actual kernel code?  I am not sure whether people generally want
to see ayet another packet filter in Linux ;)

Regards,
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
