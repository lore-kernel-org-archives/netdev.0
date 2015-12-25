From: Junxiao Bi <junxiao.bi@oracle.com>
Subject: Re: linux-next: kernel panic in ipv6_defrag
Date: Fri, 25 Dec 2015 09:21:38 +0800
Message-ID: <567C9A22.7090300@oracle.com>
References: <567A0DCD.3060001@oracle.com>
 <20151223085947.GD9692@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-next@vger.kernel.org,
	Linux Kernel mailing list <linux-kernel@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151223085947.GD9692@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2015 04:59 PM, Florian Westphal wrote:
> Junxiao Bi <junxiao.bi@oracle.com> wrote:
>> The following panic happened when I run ocfs2-test on linux-next. Kernel
>> config is attached.
>>
>> [64910.905501] BUG: unable to handle kernel NULL pointer dereference at
>>           (null)
>> [64910.906466] IP: [<ffffffff8183cc8d>] nf_ct_frag6_gather+0x7ad/0x9c0
> [..]
>> ocfs2_stack_o2cb(O) ocfs2_dlm(O) ocfs2_nodemanager(O) ocfs2_stackglue(O)
>> iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi xen_kbdfront
>> xen_netfront xen_fbfront xen_blkfront [last unloaded: ocfs2_stackglue]
>> [64910.906466] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O
>> 4.4.0-rc5-next-20151217 #1
> 
> Seems like this snapshot still lacks
> 
> e97ac12859dbf4d3ee0eddb9798867541d1d1e1e
> ("netfilter: ipv6: nf_defrag: fix NULL deref panic"),
> https://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/commit/net/ipv6/netfilter/nf_conntrack_reasm.c?id=e97ac12859dbf4d3ee0eddb9798867541d1d1e1e
> 
> Its included starting with next-20151221.
> 
> Please report back if it occurs with above commit present.
Looks issue resolved with this fix. Thank you.
> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 
