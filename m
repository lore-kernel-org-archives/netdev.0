From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: ip: Do not allow connection to remote port zero
Date: Thu, 12 Feb 2015 16:54:10 +0300
Message-ID: <54DCB082.2040207@cogentembedded.com>
References: <20150212005844.GB3829@nwwn.com> <1423713974.4942.9.camel@edumazet-glaptop2.roam.corp.google.com> <20150212052428.GB10785@eden.sea.cyngn.com> <20150212062335.GA12626@eden.sea.cyngn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Marshall <tom@cyngn.com>, Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:38853 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932238AbbBLNyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 08:54:12 -0500
Received: by mail-lb0-f178.google.com with SMTP id w7so9572565lbi.9
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 05:54:10 -0800 (PST)
In-Reply-To: <20150212062335.GA12626@eden.sea.cyngn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/12/2015 9:23 AM, Tom Marshall wrote:

>> * UDP packets with dport=0 are already prevented from being sent.

> FYI, I tried to trace where this code (disallowing udp packets with dport=0)
> came from.  It predates git history, and I don't have any way to access
> anything prior.

    Tried https://git.kernel.org/cgit/linux/kernel/git/tglx/history.git/?

WBR, Sergei
