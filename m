From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2 net-next 0/12] bpf: map pre-alloc
Date: Tue, 8 Mar 2016 15:05:54 -0800
Message-ID: <20160308230552.GA37749@ast-mbp.thefacebook.com>
References: <1457416641-306326-1-git-send-email-ast@fb.com>
 <20160308.153110.1923630451376696677.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ast@fb.com, daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	tom.zanussi@linux.intel.com, wangnan0@huawei.com,
	hekuang@huawei.com, kafai@fb.com, brendan.d.gregg@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35984 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbcCHXF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 18:05:58 -0500
Content-Disposition: inline
In-Reply-To: <20160308.153110.1923630451376696677.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 08, 2016 at 03:31:10PM -0500, David Miller wrote:
...
> > Patch 10: stress test for hash map infra. It attaches to spin_lock
> > functions and bpf_map_update/delete are called from different contexts
> > Patch 11: stress for bpf_get_stackid
> > Patch 12: map performance test
> > 
> > Reported-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
> > Reported-by: Tom Zanussi <tom.zanussi@linux.intel.com>
> 
> Series applied, thanks Alexei.

Thanks.
Just realized that I fat fingered extra zero in 'git send-mail 000*.patch'
and last 3 patches didn't reach the list.
They didn't change from v1 though. Resending them in a second.
