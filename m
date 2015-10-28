From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [RFC PATCH net-next 1/4] perf tools: Enable pre-event inherit
 setting by config terms
Date: Wed, 28 Oct 2015 15:17:46 +0100
Message-ID: <20151028141746.GA11769@krava.brq.redhat.com>
References: <1446029705-199659-1-git-send-email-wangnan0@huawei.com>
 <1446029705-199659-2-git-send-email-wangnan0@huawei.com>
 <20151028132126.GD5216@krava.brq.redhat.com>
 <20151028134213.GC18670@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wang Nan <wangnan0@huawei.com>, ast@kernel.org,
	brendan.d.gregg@gmail.com, jolsa@kernel.org, lizefan@huawei.com,
	pi3orama@163.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexei Starovoitov <ast@plumgrid.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151028134213.GC18670@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2015 at 10:42:13AM -0300, Arnaldo Carvalho de Melo wrote:
> Em Wed, Oct 28, 2015 at 02:21:26PM +0100, Jiri Olsa escreveu:
> > On Wed, Oct 28, 2015 at 10:55:02AM +0000, Wang Nan wrote:
> > > @@ -55,6 +56,7 @@ struct perf_evsel_config_term {
> > >  		bool	time;
> > >  		char	*callgraph;
> > >  		u64	stack_user;
> > > +		u64	inherit;
> > 
> > seems like bool would be enough
> 
> Ok, will change this and move it to a more suitable place member
> alignment wise.
> 
> Can I, with this change, slap an Acked-by: jirka?

yep

jirka
