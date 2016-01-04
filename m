From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [RFC PATCH 02/12] net: sched: free per cpu bstats
Date: Mon, 04 Jan 2016 16:21:25 +0100
Message-ID: <568A8DF5.7030505@iogearbox.net>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810> <20151230175130.26257.98195.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, eric.dumazet@gmail.com,
	jhs@mojatatu.com, aduyck@mirantis.com, brouer@redhat.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41611 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbcADPVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 10:21:33 -0500
In-Reply-To: <20151230175130.26257.98195.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2015 06:51 PM, John Fastabend wrote:
> When a qdisc is using per cpu stats only the bstats are being
> freed. This also free's the qstats.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Seems like a bug fix, current code seems to free this only in error
path in qdisc_create(). Should this go to -net as an individual one?

Thanks,
Daniel
