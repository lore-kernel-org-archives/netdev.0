From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH iproute2] geneve: fix IPv6 remote address reporting
Date: Fri, 6 May 2016 16:14:11 +0100
Message-ID: <572CB4C3.3040708@solarflare.com>
References: <572CAA09.302@solarflare.com>
 <20160506144345.GC11058@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:3647 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111AbcEFPO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 11:14:28 -0400
In-Reply-To: <20160506144345.GC11058@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/16 15:43, Phil Sutter wrote:
> On Fri, May 06, 2016 at 03:28:25PM +0100, Edward Cree wrote:
>> Since we can only configure unicast, we probably want to be able to
>> display unicast, rather than multicast.
> Furthermore, the kernel even rejects multicast peer addresses.
Yes, but a future kernel might not, and iproute2 is meant to be forward-
compatible.

> Why do you then propose a dubious fix to a dubious check instead of
> getting rid of it in the first place?
Because John Linville clearly had some reason for putting a check there,
and he probably knows better than me.  Chesterton's fence.

-Ed
