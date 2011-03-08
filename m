From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] Make CUBIC Hystart more robust to RTT variations
Date: Tue, 8 Mar 2011 10:21:16 +0000 (UTC)
Message-ID: <il4vur$3ka$1@dough.gmane.org>
References: <20110308093215.GA23842@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:35154 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751239Ab1CHKVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2011 05:21:32 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Pwu2i-0002ns-Ei
	for netdev@vger.kernel.org; Tue, 08 Mar 2011 11:21:30 +0100
Received: from 123.135.217.68 ([123.135.217.68])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 11:21:28 +0100
Received: from xiyou.wangcong by 123.135.217.68 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 11:21:28 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Mar 2011 10:32:15 +0100, Lucas Nussbaum wrote:
> +               {
> +//                     printk("hystart_update: cwnd=%u found=%d
> delay_min=%u cur_jif=%u round_start=%u curr_rtt=%u\n", tp->snd_cwnd,
> ca->found, ca

Please remove this line from your patch.

