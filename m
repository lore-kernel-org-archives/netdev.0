From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 net-next 2/5] net_sched: act_bpf: remove unnecessary
 copy
Date: Wed, 26 Aug 2015 10:08:12 +0200
Message-ID: <55DD73EC.6090408@iogearbox.net>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com> <1440558395-7765-3-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53539 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756646AbbHZIIO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 04:08:14 -0400
In-Reply-To: <1440558395-7765-3-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2015 05:06 AM, Alexei Starovoitov wrote:
> Fix harmless typo and avoid unnecessary copy of empty 'prog' into
> unused 'strcut tcf_bpf_cfg old'.
>
> Fixes: f4eaed28c783 ("act_bpf: fix memory leaks when replacing bpf programs")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Correct tag is actually net-next commit a5c90b29e5cc ("act_bpf: properly
support late binding of bpf action to a classifier").

Thanks for catching it!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
