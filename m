From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 07/53] tools: Move Makefile.arch from perf/config to
 tools/scripts
Date: Mon, 11 Jan 2016 11:10:59 -0300
Message-ID: <20160111141059.GA18367@kernel.org>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
 <1452520124-2073-8-git-send-email-wangnan0@huawei.com>
 <5693B3A6.6040508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, lizefan@huawei.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	"Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
To: "Wangnan (F)" <wangnan0@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5693B3A6.6040508@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Mon, Jan 11, 2016 at 09:52:38PM +0800, Wangnan (F) escreveu:
> 
> 
> On 2016/1/11 21:47, Wang Nan wrote:
> >After this patch other directories can use this architecture detector
> >without directly including it from perf's directory. Libbpf would
> >utilize it to get proper $(ARCH) so it can receive correct uapi include
> >directory.
> >
> >Signed-off-by: Wang Nan <wangnan0@huawei.com>
> >Signed-off-by: Arnaldo Carvalho de Melo <acme@kernel.org>
> >[Add missing srctree definition in tests/make]
> Hi Arnaldo, I guess you will be okay provide your SOB so I add it here.
> You didn't provide it on your original code.

Sure, and I'll cherry pick this into perf/urgent, to get the PowerPC
build fixed.

- Arnaldo
