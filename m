From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH v2 2/2] [iproute2/tc] hfsc: add link layer overhead adaption
Date: Tue, 24 Jun 2008 11:14:40 +0100
Message-ID: <4860C910.4050703@andyfurniss.entadsl.com>
References: <20080624085514.22540.91038.stgit@fate.lan> <20080624085519.22540.40534.stgit@fate.lan>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:56859 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753699AbYFXKOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2008 06:14:45 -0400
In-Reply-To: <20080624085519.22540.40534.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Patch adds 'mpu', 'mtu', 'overhead' and 'linklayer' options to hfsc. These
> options are used to create size table for sch_hfsc. Size table is only used
> and passed to kernel if these options are used.

> +	unsigned short overhead = 0, mpu = 0;

overhead may need to be negative because skb->len on eth is payload + 14

Andy.


