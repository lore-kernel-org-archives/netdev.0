From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [PATCH 1/2] tcp: refactor tcp_retransmit_skb() for a single
 return point
Date: Tue, 20 Dec 2011 11:55:37 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFAEB9@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA650@USINDEVS02.corp.hds.com>
 <AE90C24D6B3A694183C094C60CF0A2F6D8AF19@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	Seiji Aguchi <seiji.aguchi@hds.com>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps06.hds.com ([207.126.252.19]:38944 "EHLO
	usindpps06.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab1LTQ43 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 11:56:29 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6D8AF19@saturn3.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2011 07:10 AM, David Laight wrote:
>  
>> This is just a cleanup patch for making easy to hook return value 
>> with a tracepoint.
> 
> Another way to temporarily add such a trace, is to temporarily
> add a wrapper function.

I'm afraid that I don't know how to add a wrapper function temporarily.
Could you please tell me how to do that? Jprobe?

Regards,
Satoru
