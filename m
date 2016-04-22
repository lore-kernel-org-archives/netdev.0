From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net 2/3] gre: build header correctly for collect metadata tunnels
Date: Fri, 22 Apr 2016 14:05:06 -0700
Message-ID: <CAOrHB_CbD7ycnSJ4ewkj1WOu-qnYmwAYtusj1M4cfAhtN5J20Q@mail.gmail.com>
References: <cover.1461346798.git.jbenc@redhat.com>
	<7778b1a1e2123d3c9bf541d671fe62caeb6e9fd5.1461346798.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay5-d.mail.gandi.net ([217.70.183.197]:51634 "EHLO
	relay5-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbcDVVFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 17:05:12 -0400
Received: from mfilter38-d.gandi.net (mfilter38-d.gandi.net [217.70.178.169])
	by relay5-d.mail.gandi.net (Postfix) with ESMTP id 6BF5541C086
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:05:09 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
	by mfilter38-d.gandi.net (mfilter38-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
	with ESMTP id nHOmwS5JEVwm for <netdev@vger.kernel.org>;
	Fri, 22 Apr 2016 23:05:07 +0200 (CEST)
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	(Authenticated sender: pshelar@ovn.org)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 622D741C089
	for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 23:05:07 +0200 (CEST)
Received: by mail-ig0-f182.google.com with SMTP id bi2so23866466igb.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 14:05:07 -0700 (PDT)
In-Reply-To: <7778b1a1e2123d3c9bf541d671fe62caeb6e9fd5.1461346798.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 10:44 AM, Jiri Benc <jbenc@redhat.com> wrote:
> In ipgre (i.e. not gretap) + collect metadata mode, the skb was assumed to
> contain Ethernet header and was encapsulated as ETH_P_TEB. This is not the
> case, the interface is ARPHRD_IPGRE and the protocol to be used for
> encapsulation is skb->protocol.
>
> Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Pravin B Shelar <pshelar@ovn.org>
