From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [PATCH v2 0/2] Tracepoint for tcp retransmission
Date: Mon, 6 Feb 2012 13:32:33 -0500
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9CB8E7B0F3@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB728DD67@USINDEVS02.corp.hds.com>
 <20120120.135028.1359677274445012541.davem@davemloft.net>
 <65795E11DBF1E645A09CEC7EAEE94B9CB8D3EA7B@USINDEVS02.corp.hds.com>
 <CAK6E8=e-7aPTqKAidT7XJE1D8zheBj=GMApN8rSxQX8YP-Berw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	"tgraf@infradead.org" <tgraf@infradead.org>,
	"stephen.hemminger@vyatta.com" <stephen.hemminger@vyatta.com>,
	"hagen@jauu.net" <hagen@jauu.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindpps06.hds.com ([207.126.252.19]:58815 "EHLO
	usindpps06.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756Ab2BFScw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 13:32:52 -0500
In-Reply-To: <CAK6E8=e-7aPTqKAidT7XJE1D8zheBj=GMApN8rSxQX8YP-Berw@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2012 11:40 PM, Yuchung Cheng wrote:
> I totally understand that you need deeper instrumentation for *your* 
> business. At Google, we instrument a lot more in TCP as well. But we 
> have yet to upstream these changes because it's not universally useful 
> for default Linux kernel. I failed to see how different failures of a 
> TCP retransmission must be recorded and exported. Could you elaborate 
> your last point?

Hi Yuchung,

Ultimately, we'd like to record all the tcp retransmission failures
but for the first step, we'd like to know whether kernel succeeded
retransmission or not (kernel sent a packet or not).

Does it make sense?

Regards,
Satoru
