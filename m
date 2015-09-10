From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v2] net: Remove VRF change to udp_sendmsg
Date: Wed, 09 Sep 2015 20:20:26 -0700 (PDT)
Message-ID: <20150909.202026.215174674574675091.davem@davemloft.net>
References: <CALx6S35scg=6vr9zPBD=_VPHGDwkq22hQM4Ce2roi4j5DXrYZw@mail.gmail.com>
	<55F0CD92.7080700@cumulusnetworks.com>
	<CALx6S35Fwu5QsR-W=0LVzvZv_PGqbV3TGR9T5YRU65QCY0OgzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36888 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422AbbIJDUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 23:20:30 -0400
In-Reply-To: <CALx6S35Fwu5QsR-W=0LVzvZv_PGqbV3TGR9T5YRU65QCY0OgzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Wed, 9 Sep 2015 17:51:19 -0700

> Consider that ip_local_out_sk calls netfilter NF_INET_LOCAL_OUT hook
> before dst->output, so then netfilter would start seeing packets
> with zero source address???

I have to agree with Tom here, this is fatal.
