From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Sun, 12 Apr 2015 18:03:43 -0700
Message-ID: <20150413010342.GA1672@Alexeis-MBP.westell.com>
References: <20150412075351.GA2112@nanopsycho.orion>
 <20150412.194443.1571071793033525091.davem@davemloft.net>
 <20150413001212.GA1656@Alexeis-MBP.westell.com>
 <20150412.203618.86474109049619893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, netdev@vger.kernel.org, jhs@mojatatu.com,
	tgraf@suug.ch, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34169 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbDMBDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 21:03:48 -0400
Received: by pdbqa5 with SMTP id qa5so89139597pdb.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 18:03:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150412.203618.86474109049619893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 12, 2015 at 08:36:18PM -0400, David Miller wrote:
> 
> It's easy to parameterize what flow dissector does and share code.

yes. Though I wouldn't pessimize ixgbe rx path even by single
cycle to accommodate openflow spec. As far as I understand the
skb_flow_dissect() job from driver point of view is to figure
out header length for copybreak, which includes parsing encaps,
whereas openflow stops at outer header. Even with this difference,
it surely can be parameterized. Would be great to share if it
doesn't cost rx anything.
