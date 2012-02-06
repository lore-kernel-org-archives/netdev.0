From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 6 Feb 2012 13:21:37 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB8E7B0D4@USINDEVS02.corp.hds.com>
References: <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <20120204142823.GA7000@neilslaptop.think-freely.org>
 <20120204155807.GA2657@nuttenaction>
 <20120204200937.GA2670@neilslaptop.think-freely.org>
 <20120205125325.GA31578@elastic.org>
 <20120205191708.GA5337@neilslaptop.think-freely.org>
 <20120205200428.GB2816@nuttenaction>
 <20120206013247.GA5681@neilslaptop.think-freely.org>
 <20120206152019.GG27935@redhat.com>
 <20120206155305.GB3620@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	"Frank Ch. Eigler" <fche@elastic.org>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	"fche@sourceware.org" <fche@sourceware.org>,
	"mathieu.desnoyers@polymtl.ca" <mathieu.desnoyers@polymtl.ca>,
	"rostedt@goodmis.org" <rostedt@goodmis.org>
To: Neil Horman <nhorman@tuxdriver.com>,
	"Frank Ch. Eigler" <fche@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps03.hds.com ([207.126.252.16]:51184 "EHLO
	usindpps03.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab2BFSWy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 13:22:54 -0500
In-Reply-To: <20120206155305.GB3620@hmsreliant.think-freely.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2012 10:53 AM, Neil Horman wrote:
> On Mon, Feb 06, 2012 at 10:20:19AM -0500, Frank Ch. Eigler wrote:
>> On Sun, Feb 05, 2012 at 08:32:47PM -0500, Neil Horman wrote:
>>
> Yes, that was his point.  Mine was that, given Satoru's needs, a 
> netfilter hook provides 90% of what they need (as its been described 
> here).  If you're unfamiliar with them, netfilter hooks are those 
> standard points in the network input/output/forwarding paths at which 
> we can watch and maniupulate network traffic.  They're what 
> iptables/ip6tables/ebtables/etc use to do everything they do.  I'm 
> suggesting that they use those existing hooks to monitor outgoing 
> traffic for whatever information they want (in this case
> retransmitted unacked tcp sequence numbers).  Or whatever else their
> interested in.
> 
> As for the other 10% (recording failed retransmits, which don't 
> generate traffic), we have existing tracepoints that can be used.

Thank you so much, Neil and other guys.

For now it seems to be difficult to move into netfilter approach
because "other 10%" is so important for us. But first, I'll consider
it more deeply.

Regards,
Satoru
