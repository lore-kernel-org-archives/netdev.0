From: Patrick McHardy <kaber@trash.net>
Subject: Re: GVRP
Date: Tue, 27 May 2008 19:43:06 +0200
Message-ID: <483C482A.3050003@trash.net>
References: <483C328B.7040007@trash.net> <alpine.LRH.1.10.0805271936140.13277@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59620 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755390AbYE0RnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 13:43:09 -0400
In-Reply-To: <alpine.LRH.1.10.0805271936140.13277@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka Savola wrote:
> On Tue, 27 May 2008, Patrick McHardy wrote:
>> I've written an applicant-only GVRP implementation for the kernel
>> some time ago (for those not familiar: it dynamically registers
>> VLANs with switches. Applicant-only means its only the "client-side")
>> and I'm wondering whether I should merge it. It should be quite
>> easy to move it to userspace, OTOH I think it would be nice to
>> have the client-side support for this without having to install
>> additional daemons. But since this is not a really strong argument,
>> I'd like to hear if anyone has an opinion about this.
>>
>> The GVRP implementation sits on top of an GARP implementation,
>> which could also support GMRP for multicast address registrations.
>>
>> I'm not including the patch yet because it would need to be
>> split up and needs some minor cleanups, just for orientation, the
>> GARP implementation is about 600 lines of simple code, the GVRP
>> implementation something like 60 lines of even simpler code.
> 
> If it's simple, why not?
> 
> But-- when I was writing RFC 5110 one of the things we evaluated was 
> whether an another application of GARP, GMRP, could be used.
> 
> We asked IEEE about this and they said that GARP and GMRP are obsolete, 
> below is the most important part of RFC 5110 with this respect:
> 
>    IEEE 802.1D-2004 specification describes Generic Attribute
>    Registration Protocol (GARP), and GARP Multicast Registration
>    Protocol (GMRP) [GMRP] is a link-layer multicast group application of
>    GARP that notifies switches about MAC multicast group memberships.
>    If GMRP is used in conjunction with IP multicast, then the GMRP
>    registration function would become associated with an IGMP "join".
>    However, this GMRP-IGMP association is beyond the scope of GMRP.
>    GMRP requires support at the host stack and it has not been widely
>    implemented.  Further, IEEE 802.1 considers GARP and GMRP obsolete
>    being replaced by Multiple Registration Protocol (MRP) and Multicast
>    Multiple Registration Protocol (MMRP) that are being specified in
>    IEEE 802.1ak [802.1ak].  MMRP is expected to be mainly used between
>    bridges.  Some further information about GARP/GMRP is also available
>    in Appendix B of [RFC3488].


Thanks for the pointer, I'll try to read up on this tommorrow.
If GARP is considered obsolete, I guess there's no point in
merging GVRP.



