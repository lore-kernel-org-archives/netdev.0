From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 42/53] perf record: Prevent reading invalid data in
 record__mmap_read
Date: Mon, 11 Jan 2016 13:01:53 -0200
Message-ID: <20160111150153.GE21083@redhat.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-43-git-send-email-wangnan0@huawei.com>
 <5693BA78.70606@cogentembedded.com>
 <20160111150007.GD21083@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, acme@kernel.org,
	linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	He Kuang <hekuang@huawei.com>, Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160111150007.GD21083@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 01:00:07PM -0200, Arnaldo Carvalho de Melo escreveu:
> Em Mon, Jan 11, 2016 at 05:21:44PM +0300, Sergei Shtylyov escreveu:
> > On 01/11/2016 04:48 PM, Wang Nan wrote:
> > >  	size = head - old;
> > >+	if (size > (unsigned long)(md->mask) + 1) {
> > >+		WARN_ONCE(1, "WARNING: failed to keep up with mmap data. (warn only once)\n");
> > 
> >    WARNING is already printed by WARN*(), no?
> 
> No, at least not in tools/include/asm/bug.h, perhaps include/asm/bug.h
> has this now and tools/ drifted? Checking now...

Indeed, need to bring it closer together again...

- Arnaldo
