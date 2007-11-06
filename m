From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bizarre network timing problem
Date: Tue, 06 Nov 2007 13:12:13 -0800
Message-ID: <4730D8AD.5060401@hp.com>
References: <20071017205127.GA21334@codeblau.de> <47167BDE.4000103@redhat.com>	<20071017220019.GA22765@codeblau.de> <471689BF.2040909@hp.com>	<20071018094230.GA2978@codeblau.de> <4717964A.8080100@hp.com>	<20071102221146.GA4354@codeblau.de> <472BA5BC.6000901@hp.com>	<20071102223856.GA5121@codeblau.de> <472BAB90.8020306@hp.com> <20071102232332.GA5739@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chuck Ebbert <cebbert@redhat.com>, linux-kernel@vger.kernel.org,
	Netdev <netdev@vger.kernel.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:35976 "EHLO palrel11.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754184AbXKFVMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 16:12:16 -0500
In-Reply-To: <20071102232332.GA5739@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Felix von Leitner wrote:
> Thus spake Rick Jones (rick.jones2@hp.com):
> 
>>Past performance is no guarantee of current correctness :)  And over an 
>>Ethernet, there will be a very different set of both timings and TCP 
>>segment sizes compared to loopback.
> 
>>My guess is that you will find setting the lo mtu to 1500 a very 
>>interesting experiment.
> 
> Setting the MTU on lo to 1500 eliminates the problem and gives me double
> digit MB/sec throughput.

I'm not in a position at the moment to test it as my IPoIB systems are offline, 
and not sure you are either, but I will note that with IPoIB bits circa OFED1.2 
the default MTU for IPoIB goes up to 65520 bytes.  If indeed the problem you 
were seeing was related to sub-mss sends and window probing and such, it might 
appear on IPoIB in addition to loopback.

rick jones
