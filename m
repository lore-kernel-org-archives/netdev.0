From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v5 2/3] bpf: Add bpf_current_task_under_cgroup
 helper
Date: Fri, 12 Aug 2016 18:01:56 +0200
Message-ID: <57ADF2F4.9080309@iogearbox.net>
References: <20160812155650.GA12886@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tj@kernel.org
To: Sargun Dhillon <sargun@sargun.me>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:60651 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752328AbcHLQUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 12:20:30 -0400
In-Reply-To: <20160812155650.GA12886@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2016 05:56 PM, Sargun Dhillon wrote:
> This adds a bpf helper that's similar to the skb_in_cgroup helper to check
> whether the probe is currently executing in the context of a specific
> subset of the cgroupsv2 hierarchy. It does this based on membership test
> for a cgroup arraymap. It is invalid to call this in an interrupt, and
> it'll return an error. The helper is primarily to be used in debugging
> activities for containers, where you may have multiple programs running in
> a given top-level "container".
>
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>
> Acked-by: Tejun Heo <tj@kernel.org>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Looks good, thanks, Sargun!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
