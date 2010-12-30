From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [net-next-2.6 PATCH v2 3/3] net_sched: implement a root container
 qdisc sch_mclass
Date: Fri, 31 Dec 2010 00:56:14 +0100
Message-ID: <4D1D1C1E.5040800@gmail.com>
References: <20101221192831.9703.56356.stgit@jf-dev1-dcblab> <20101221192930.9703.63791.stgit@jf-dev1-dcblab> <4D1D17C9.3040500@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, hadi@cyberus.ca,
	shemminger@vyatta.com, tgraf@infradead.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, nhorman@tuxdriver.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:34203 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751807Ab0L3X4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 18:56:21 -0500
Received: by bwz15 with SMTP id 15so12083492bwz.19
        for <netdev@vger.kernel.org>; Thu, 30 Dec 2010 15:56:20 -0800 (PST)
In-Reply-To: <4D1D17C9.3040500@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> John Fastabend wrote:
...
>> +	for (i = 0; i < dev->num_tc; i++) {
>> +		dev_queue = netdev_get_tx_queue(dev, dev->tc_to_txq[i].offset);
> 
> Are these offsets etc. validated?

They are... Forget this last question.

Jarek P.
