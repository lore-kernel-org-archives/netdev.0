From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Cleanup include/net/tcp.h include-files and
 coding-style
Date: Sun, 09 Jan 2011 23:06:29 +0000
Message-ID: <1294614389.2823.35.camel@localhost>
References: <1294606534-28522-1-git-send-email-christoph.paasch@uclouvain.be>
	 <201101092232.19171.christoph.paasch@uclouvain.be>
	 <1294610141.2823.31.camel@localhost>
	 <201101092333.19406.christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101092333.19406.christoph.paasch@uclouvain.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2011-01-09 at 23:33 +0100, Christoph Paasch wrote:
> On Sunday, January 09, 2011 wrote Ben Hutchings:
> > The cost of repeated inclusion is minimal.  GCC's preprocessor
> > recognises when the entire content of a file is conditional on #ifndef
> > FOO and will not even open it again if FOO is defined.
> Thanks, I did not knew about that.
> 
> > If a file directly references definitions that are supposed to be
> > provided by a certain header, changing it to rely on indirect inclusion
> > of that header generally does *not* aid maintenance.
> But then, to be coherent, we would need to add the following includes (and I'm 
> even not 100% sure if it's all we need):
> 
> linux/percpu_counter.h (needed for percpu_counter_sum_positive)

Yes.

> linux/mm_types.h (needed for struct page)
> linux/aio.h (needed for struct kiocb)
> net/inet_sock.h (needed for struct ip_options)
> linux/pipe_fs_i.h (needed for struct pipe_inode_info)
> linux/poll.h (needed for struct poll_table_struct)

Or declarations of those structs.

> linux/compiler.h (needed for __percpu)
[...]

Yes.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
