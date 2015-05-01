From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: sched: run ingress qdisc without locks
Date: Fri, 01 May 2015 14:41:14 +0200
Message-ID: <5543746A.7080803@iogearbox.net>
References: <1430450047-5671-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40220 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635AbbEAMlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 08:41:24 -0400
In-Reply-To: <1430450047-5671-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/01/2015 05:14 AM, Alexei Starovoitov wrote:
> TC classifiers/actions were converted to RCU by John in the series:
> http://thread.gmane.org/gmane.linux.network/329739/focus=329739
> and many follow on patches.
> This is the last patch from that series that finally drops
> ingress spin_lock.
>
> Single cpu ingress+u32 performance goes from 22.9 Mpps to 24.5 Mpps.
>
> In two cpu case when both cores are receiving traffic on the same
> device and go into the same ingress+u32 the performance jumps
> from 4.5 + 4.5 Mpps to 23.5 + 23.5 Mpps
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Looks good to me, thanks!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
