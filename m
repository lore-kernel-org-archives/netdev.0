From: Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v3 2/4] net_dma: revert 'copied_early'
Date: Mon, 13 Jan 2014 22:04:20 -0800
Message-ID: <CAPcyv4ha6gt+xB5K02YOuOcKsWH6GCKvhsjs+ZSTqzAtqE5oFA@mail.gmail.com>
References: <20140114004509.27138.50345.stgit@viggo.jf.intel.com>
	<20140114004637.27138.50365.stgit@viggo.jf.intel.com>
	<20140113.211619.613683326137425186.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "dmaengine@vger.kernel.org" <dmaengine@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>, saidi@engin.umich.edu,
	James Morris <jmorris@namei.org>, edumazet@google.com,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Dave Jones <davej@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Patrick McHardy <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:39183 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbaANGEV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:04:21 -0500
Received: by mail-ve0-f177.google.com with SMTP id pa12so1737431veb.36
        for <netdev@vger.kernel.org>; Mon, 13 Jan 2014 22:04:20 -0800 (PST)
In-Reply-To: <20140113.211619.613683326137425186.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 9:16 PM, David Miller <davem@davemloft.net> wrote:
> From: Dan Williams <dan.j.williams@intel.com>
> Date: Mon, 13 Jan 2014 16:47:14 -0800
>
>> Now that tcp_dma_try_early_copy() is gone nothing ever sets
>> copied_early.
>>
>> Also reverts "53240c208776 tcp: Fix possible double-ack w/ user dma"
>> since it is no longer necessary.
>>
>> Cc: Ali Saidi <saidi@engin.umich.edu>
>> Cc: James Morris <jmorris@namei.org>
>> Cc: Patrick McHardy <kaber@trash.net>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
>> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
>> Cc: Neal Cardwell <ncardwell@google.com>
>> Reported-by: Dave Jones <davej@redhat.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Acked-by: David S. Miller <davem@davemloft.net>

Thank you sir.
