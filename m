From: Steven Blake <slblake@petri-meat.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Tue, 12 Jan 2010 23:47:45 -0500
Message-ID: <9440ce557c65a3d9ae7d3c5d4443792a@petri-meat.com>
References: <201001121432.43301.schmto@hrz.tu-chemnitz.de>	<20100112.121607.39835310.davem@davemloft.net>	<4B4CE2B8.1040702@redfish-solutions.com> <20100112.130355.144803575.davem@davemloft.net> <4B4CEA91.3070201@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elom.tchmachines.com ([208.76.80.198]:33706 "EHLO
	elom.tchmachines.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab0AMFTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 00:19:24 -0500
In-Reply-To: <4B4CEA91.3070201@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2010 13:33:05 -0800, "Philip A. Prindeville"
<philipp_subx@redfish-solutions.com> wrote:

> On 01/12/2010 01:03 PM, David Miller wrote:

>> What they do is they have a set of semantics inside of their cloud of
>> routers and switch points for diffserv, and when packets come in the
>> TOS field is rewritten to whatever scheme is being used inside of that
>> cloud.
> 
> Uh, no.  Net Neutrality very much requires consistent end-to-end
> interpretation of ToS bits by backbone carriers.  If you know of a
carrier
> that isn't honoring ToS bits, I have a group of lawyers I'd like them to
> meet.

Few if any ISPs are honoring any DSCP bits outside of negotiated contracts.

 
>> And the diffserv bits only have meaning and effect within that cloud.
> 
> Have you read RFC-2474 lately?  You only need to get as far as the
> Abstract:
> 
>    The services may be either end-to-end or intra-domain; they include
>    both those that can satisfy quantitative performance requirements
(e.g.,
>    peak bandwidth) and those based on relative performance (e.g., "class"
>    differentiation).
> 
> "end-to-end"... seems pretty clear to me.

David's understanding of RFC 2474 is correct.


Regards,

// Steve
