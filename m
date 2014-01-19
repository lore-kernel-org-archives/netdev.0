From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: introduce SO_BPF_EXTENSIONS
Date: Sat, 18 Jan 2014 19:09:16 -0800 (PST)
Message-ID: <20140118.190916.636296905840181243.davem@davemloft.net>
References: <1389974985-21160-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msekleta@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54104 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752556AbaASDJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jan 2014 22:09:20 -0500
In-Reply-To: <1389974985-21160-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Sekletar <msekleta@redhat.com>
Date: Fri, 17 Jan 2014 17:09:45 +0100

> For user space packet capturing libraries such as libpcap, there's
> currently only one way to check which BPF extensions are supported
> by the kernel, that is, commit aa1113d9f85d ("net: filter: return
> -EINVAL if BPF_S_ANC* operation is not supported"). For querying all
> extensions at once this might be rather inconvenient.
> 
> Therefore, this patch introduces a new option which can be used as
> an argument for getsockopt(), and allows one to obtain information
> about which BPF extensions are supported by the current kernel.
> 
> As David Miller suggests, we do not need to define any bits right
> now and status quo can just return 0 in order to state that this
> versions supports SKF_AD_PROTOCOL up to SKF_AD_PAY_OFFSET. Later
> additions to BPF extensions need to add their bits to the
> bpf_tell_extensions() function, as documented in the comment.
> 
> Signed-off-by: Michal Sekletar <msekleta@redhat.com>
> Cc: David Miller <davem@davemloft.net>
> Reviewed-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
