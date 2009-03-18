From: Ingo Molnar <mingo@elte.hu>
Subject: Re: e1000e 0000:00:19.0: DMA-API: device driver tries
	to free DMA	memory it has not allocated [device
	address=0x0000000052ff084a]	[size=90 bytes]
Date: Wed, 18 Mar 2009 17:47:31 +0100
Message-ID: <20090318164731.GB31315@elte.hu>
References: <1237223130-26519-1-git-send-email-joerg.roedel@amd.com>
	<20090317120112.GP6159@amd.com> <20090318093847.GC5879@elte.hu>
	<20090318115615.GS6159@amd.com> <20090318120458.GA1601@elte.hu>
	<36697.89.102.207.186.1237380871.squirrel@mail.v3.sk>
	<20090318140949.GA20852@elte.hu>
	<F169D4F5E1F1974DBFAFABF47F60C10A1E8795AC@orsmsx507.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Lubomir Rintel <lkundrak@v3.sk>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	"Ronciak, John" <john.ronciak@intel.com>, "Kirsher,
	Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Joerg Roedel <joerg.roedel@amd.com>, Ingo Molnar <mingo@redhat.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <F169D4F5E1F1974DBFAFABF47F60C10A1E8795AC@orsmsx507.amr.corp.intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* Brandeburg, Jesse <jesse.brandeburg@intel.com> wrote:

> Ingo Molnar wrote:
> > * Lubomir Rintel <lkundrak@v3.sk> wrote:
> > 
> >> On Wed, March 18, 2009 8:04 am, Ingo Molnar wrote:
> >>> 
> >>> ( e1000e Cc:s added. A new debug feature, CONFIG_DMA_API_DEBUG=y,
> >>>   has triggered the warning below in e1000_put_txbuf(). )
> >> 
> >> http://lkml.org/lkml/2009/3/2/318
> 
> We are still looking for more testing from the general community of 
> this patch, in particular if any tx hangs are reported.  Thanks in 
> advance for any reports.--

Yeah - already picked it up into tip:out-of-tree and it passed about 
a hundred bootup tests on various e1000e using systems already - 
with no problems whatsoever. Will let you know if anything breaks - 
e1000e has been rock solid for me in the .29 cycle.

	Ingo

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
