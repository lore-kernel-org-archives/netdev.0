From: Patrick McHardy <kaber@trash.net>
Subject: Re: nf_conntrack fix smp_processor_id() in preemptible code
Date: Wed, 27 Feb 2008 17:47:11 +0100
Message-ID: <47C5940F.7080906@trash.net>
References: <20080216002522.9c4bd0fb.akpm@linux-foundation.org> <47BC982C.7050402@imap.cc> <47BD6072.4000407@trash.net> <47C591B4.7090302@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:46742 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754576AbYB0QrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 11:47:10 -0500
In-Reply-To: <47C591B4.7090302@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tilman Schmidt wrote:
> Am 21.02.2008 12:28 schrieb Patrick McHardy:
>>> Feb 20 17:22:40 xenon kernel: [   48.180297] BUG: using smp_processor_id() in preemptible [00000000] code: ntpdate/3562
>>> Feb 20 17:22:40 xenon kernel: [   48.180297] caller is __nf_conntrack_find+0x9b/0xeb [nf_conntrack]
>>> Feb 20 17:22:40 xenon kernel: [   48.180297] Pid: 3562, comm: ntpdate Not tainted 2.6.25-rc2-mm1-testing #1
>>> Feb 20 17:22:40 xenon kernel: [   48.180297]  [<c02015b9>] debug_smp_processor_id+0x99/0xb0
>> Could you test whether this patch fixes the netfilter
>> warnings please?
> 
> Bad news: With 2.6.25-rc3, that bug has made it into mainline.
> Good news: Your patch fixes it there, too.

No, its been there since -rc1.

> So I suggest you forward it there as soon as possible.

Already done, should hit upstream soon.

