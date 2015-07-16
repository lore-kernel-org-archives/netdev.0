From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: What queues/buffers does tc-netem use?
Date: Thu, 16 Jul 2015 14:42:47 +0200 (CEST)
Message-ID: <116464048.2486.1437050567469.JavaMail.open-xchange@ox1app>
References: <ed5152b6a0e746b08b00c2dc8270afbc@ustx2ex-dag1mb3.msg.corp.akamai.com>
Reply-To: Hagen Paul Pfeifer <hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netem@osdl.org
To: netdev@vger.kernel.org, "Motejlek, Petr" <pmotejle@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.mailbox.org ([80.241.60.212]:58269 "EHLO mx1.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751048AbbGPMwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 08:52:46 -0400
In-Reply-To: <ed5152b6a0e746b08b00c2dc8270afbc@ustx2ex-dag1mb3.msg.corp.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
