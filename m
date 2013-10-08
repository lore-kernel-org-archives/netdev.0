From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH net-next v2 4/5] xen-netback: handle
 IPv6 TCP GSO packets from the guest
Date: Tue, 08 Oct 2013 14:50:21 +0100
Message-ID: <525429BD02000078000F99F6@nat28.tlf.novell.com>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-5-git-send-email-paul.durrant@citrix.com>
 <20131008133142.GJ28411@zion.uk.xensource.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD012F306@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "David Vrabel" <david.vrabel@citrix.com>,
	"Ian Campbell" <Ian.Campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Paul Durrant" <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:53355 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752390Ab3JHNu1 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Tue, 8 Oct 2013 09:50:27 -0400
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD012F306@AMSPEX01CL01.citrite.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 08.10.13 at 15:42, Paul Durrant <Paul.Durrant@citrix.com> wrote:
>>  -----Original Message-----
>> From: Wei Liu [mailto:wei.liu2@citrix.com]
>> Sent: 08 October 2013 14:32
>> To: Paul Durrant
>> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel;
>> Ian Campbell
>> Subject: Re: [PATCH net-next v2 4/5] xen-netback: handle IPv6 TCP GSO
>> packets from the guest
>> 
>> On Tue, Oct 08, 2013 at 11:58:15AM +0100, Paul Durrant wrote:
>> > This patch a xenstore flag, festure-gso-tcpv6, to adevrtise netback can
>>             ^ adds            feature               advertise
>> 
>> > handle IPv6 TCP GSO packets and creates SKB_GSO_TCPV6 skbs if the
>> frontend
>> > passes an extra segment with the new type XEN_NETIF_GSO_TYPE_TCPV6
>> added to
>> > netif.h.
>> 
>> Note the new type should be synced to Xen's netif.h tree with separate
>> patch for Xen.
>> 
> 
> Ok. Do you think it is reasonable to make incremental changes to netif.h in 
> this series and then submit a patch to xen-devel with the complete set once 
> this series is accepted?

I would think so.

Jan
