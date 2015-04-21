From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: ioremap_uc() followed by set_memory_wc() - burrying MTRR
Date: Tue, 21 Apr 2015 15:09:02 -0700
Message-ID: <CALCETrXMJNvd0zTjgyM6GF=xm7aL-K2ERX-A0p=46msh54AA7g@mail.gmail.com>
References: <1428695379.6646.69.camel@misato.fc.hp.com> <20150410210538.GB5622@wotan.suse.de>
 <1428699490.21794.5.camel@misato.fc.hp.com> <CALCETrUP688aNjckygqO=AXXrNYvLQX6F0=b5fjmsCqqZU78+Q@mail.gmail.com>
 <20150411012938.GC5622@wotan.suse.de> <CALCETrXd19C6pARde3pv-4pt-i52APtw5xs20itwROPq9VmCfg@mail.gmail.com>
 <20150413174938.GE5622@wotan.suse.de> <1429137531.1899.28.camel@palomino.walls.org>
 <20150415235816.GG5622@wotan.suse.de> <1429146457.1899.99.camel@palomino.walls.org>
 <20150421220219.GX5622@wotan.suse.de> <CAB=NE6UFOi_CYbrgYGCfU3Uki30iGdPPL2+V5RLYww=NS7G0GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Walls <awalls@md.metrocast.net>,
	Hyong-Youb Kim <hykim@myri.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Toshi Kani <toshi.kani@hp.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Sean Hefty <sean.hefty@intel.com>,
	Suresh Siddha <sbsiddha@gmail.com>,
	Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Roland Dreier <roland@purestorage.com>,
	Juergen Gross <jgross@suse.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>,
	Borislav Petkov <bp@suse.de>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	Davidlohr Bueso <dbueso@suse.de>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Thomas Gleixner <tgl
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6UFOi_CYbrgYGCfU3Uki30iGdPPL2+V5RLYww=NS7G0GA@mail.gmail.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 21, 2015 at 3:08 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
> On Tue, Apr 21, 2015 at 3:02 PM, Luis R. Rodriguez <mcgrof@suse.com> wrote:
>> Andy, can we live without MTRR support on this driver for future kernels? This
>> would only leave ipath as the only offending driver.
>
> Sorry to be clear, can we live with removal of write-combining on this driver?
>

I personally think so, but a driver maintainer's ack would be nice.

--Andy
