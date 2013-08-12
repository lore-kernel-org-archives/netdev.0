From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] ipv6: make unsolicited report intervals
 configurable for mld
Date: Mon, 12 Aug 2013 02:23:45 +0000 (UTC)
Message-ID: <ku9gvg$27t$1@ger.gmane.org>
References: <20130812014859.GA13886@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37678 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755342Ab3HLCYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Aug 2013 22:24:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1V8hnf-000279-LC
	for netdev@vger.kernel.org; Mon, 12 Aug 2013 04:24:03 +0200
Received: from 182.246.108.196 ([182.246.108.196])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 04:24:03 +0200
Received: from xiyou.wangcong by 182.246.108.196 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 04:24:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Aug 2013 at 01:48 GMT, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> Commit cab70040dfd95ee32144f02fade64f0cb94f31a0 ("net: igmp:
> Reduce Unsolicited report interval to 1s when using IGMPv3") and
> 2690048c01f32bf45d1c1e1ab3079bc10ad2aea7 ("net: igmp: Allow user-space
> configuration of igmp unsolicited report interval") by William Manley made
> igmp unsolicited report intervals configurable per interface and corrected
> the interval of unsolicited igmpv3 report messages resendings to 1s.
>
> Same needs to be done for IPv6:
>
> MLDv1 (RFC2710 7.10.): 10 seconds
> MLDv2 (RFC3810 9.11.): 1 second
>
> Both intervals are configurable via new procfs knobs
> mldv1_unsolicited_report_interval and mldv2_unsolicited_report_interval.
>

Please update the doc as well.
