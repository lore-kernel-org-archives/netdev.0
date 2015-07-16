From: "Motejlek, Petr" <pmotejle@akamai.com>
Subject: Re: What queues/buffers does tc-netem use?
Date: Thu, 16 Jul 2015 12:48:33 +0000
Message-ID: <1437050912759.32788@akamai.com>
References: <ed5152b6a0e746b08b00c2dc8270afbc@ustx2ex-dag1mb3.msg.corp.akamai.com>,<116464048.2486.1437050567469.JavaMail.open-xchange@ox1app>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netem@osdl.org" <netem@osdl.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay08.akamai.com ([96.6.114.112]:59232 "EHLO
	prod-mail-xrelay08.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751048AbbGPMsp convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 08:48:45 -0400
In-Reply-To: <116464048.2486.1437050567469.JavaMail.open-xchange@ox1app>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hagen,

Could you please give me some example of such a tc command that would tell me the statistics? I am not sure what you mean.

Is there a way I can manipulate the internal rbtree queue size, please?

Thank you

Petr MOTEJLEK
________________________________________
From: Hagen Paul Pfeifer <hagen@jauu.net>
Sent: Thursday, July 16, 2015 2:42 PM
To: netdev@vger.kernel.org; Motejlek, Petr
Cc: netem@osdl.org
Subject: Re: What queues/buffers does tc-netem use?

> On July 16, 2015 at 1:28 PM "Motejlek, Petr" <pmotejle@akamai.com>
> wrote:

> I was wondering what queues/buffers does netem use and how does one
> control or monitor them?

netem uses his own rbtree based queue. You can use tc(1) to get
statistics.

> I could not find this information anywhere and I am not that good in
> reading the sources to be able to tell enough about this :) If we talk
> only about the situation where netem is the root qdisc for a particular
> interface, I would imagine it might be using the txqueue of that
> interface, but I am not sure if that's really the case...

Saddly there is no netem implementation documentation, but the source code
is straightforward. You may take a look:

http://lxr.free-electrons.com/source/net/sched/sch_netem.c

Cheers, Hagen
