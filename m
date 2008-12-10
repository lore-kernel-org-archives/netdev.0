From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: 2.6.26.3 kernel - progressive slowdown over NFS
Date: Wed, 10 Dec 2008 13:26:28 -0800
Message-ID: <20081210132628.55991b93.akpm@linux-foundation.org>
References: <f4e12c70809091747rd58165ahaa6594a35752c6ef@mail.gmail.com>
	<slrngjt7b4.d62.davidf+nntp@dog.thdo.woaf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Ray Lee" <ray-lk-0Cg02Ec9UG4BXFe83j6qeQ@public.gmane.org>,
	"Trond Myklebust" <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>,
	pkpatel.lists-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Flynn <davidf+nntp-p1ML1wbIMYc@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <slrngjt7b4.d62.davidf+nntp-wwhKarxBCNZl29rWeyUsZ16hYfS7NtTn@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(cc's restored)

Please always do reply-to-all when working with kernel people.  It's
important.

Thanks.

On Tue, 9 Dec 2008 16:31:32 +0000 (UTC)
David Flynn <davidf+nntp-p1ML1wbIMYc@public.gmane.org> wrote:

> On 2008-09-10, Priyank Patel <pkpatel.lists-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > We have a simple python program which keeps running a C loop to lstat
> > NFS mounted directories.  We are seeing some weird behavior w.r.t. the
> > run-time of this program on 2.6.26.3 kernel vs 2.6.24 kernel.
> >
> > The run-time of the following code increases over time on the 2.6.26.3
> > kernel, whereas remains flat (as expected) on the 2.6.24 kernel.
> 
> I'm seeing a similar effect, and ran a benchmark pre and post reboot:
> 
>  $ strace -T /usr/sbin/bonnie++ -d . -s 0 -f -n 1 >/tmp/bonnie-r44237-netslow 2>&1
>  ...reboot...
>  $ strace -T /usr/sbin/bonnie++ -d . -s 0 -f -n 1 >/tmp/bonnie-r44237-netfast 2>&1
> 
> Graphs of the operations are avaliable:
>   http://davidf.woaf.net/nfsfail-2.6.26/
> 
> In particular http://davidf.woaf.net/nfsfail-2.6.26/r44237-stat.pdf
> 
> r44237-* was a machine with a 28 day uptime and
> r44088-* is an identical machine with 14 day uptime.
> 
> The graphs show times as recorded by strace for each syscall (points), a
> cumulative frequency plot is also drawn on the same graph (lines).
> yellow-orange points/lines are before the reboot, purple afterwards.
> 
> The machines are part of a cluster with a r/o nfsroot and common debian
> stock kernel:
>  Linux r44088 2.6.26-1-amd64 #1 SMP Sat Aug 2 11:15:08 GMT 2008 x86_64 GNU/Linux
> 
> Other nfs filesystems are also mounted; all nfs mounts are nfsv3 over udp.
> 
> Has this issue been identified or resolved in 2.6.27?
> 
> Extra logs can be provided if required.
> 
> ..david


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
