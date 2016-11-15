From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH v2 net-next 0/6] bpf: LRU map
Date: Tue, 15 Nov 2016 10:12:55 -0800
Message-ID: <20161115181255.GA68164@kafai-mba.local>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
 <20161115.115123.433376609853237994.davem@redhat.com>
 <20161115.115924.957021512319479216.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <ast@fb.com>, <daniel@iogearbox.net>,
        <kernel-team@fb.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:56291 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933386AbcKOSN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:13:26 -0500
Content-Disposition: inline
In-Reply-To: <20161115.115924.957021512319479216.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 11:59:24AM -0500, David Miller wrote:
> From: David Miller <davem@redhat.com>
> Date: Tue, 15 Nov 2016 11:51:23 -0500 (EST)
>
> > From: Martin KaFai Lau <kafai@fb.com>
> > Date: Fri, 11 Nov 2016 10:55:05 -0800
> >
> >> This patch set adds LRU map implementation to the existing BPF map
> >> family.
> >
> > Series applied, thanks.
>
> BTW, with Fedora 24's gcc-6.2.1 on x86_64 I'm getting this warning:
>
> kernel/bpf/bpf_lru_list.c: In function ‘__bpf_lru_list_rotate_inactive.isra.3’:
> kernel/bpf/bpf_lru_list.c:201:28: warning: ‘next’ may be used uninitialized in this function [-Wmaybe-uninitialized]
>   l->next_inactive_rotation = next;
>   ~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~~~
I will post a patch shortly.  Thanks!
