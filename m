From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Tue, 11 Feb 2014 20:17:41 -0800
Message-ID: <1392178661.1752.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1859471893.20140126115521@eikelenboom.it>
	 <20140127000305.GA14236@electric-eye.fr.zoreil.com>
	 <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
	 <84816226.20140206123631@eikelenboom.it>
	 <942972114.20140206140909@eikelenboom.it>
	 <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
	 <1434499348.20140211205617@eikelenboom.it>
	 <CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Dave Jones <davej@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-02-11 at 18:07 -0800, Dan Williams wrote:

> The overlap granularity is too large.  Multiple dma_map_single
> mappings are allowed to a given page as long as they don't collide on
> the same cache line.
> 

I am not sure why you try number of mappings of a page.

Try launching 100 concurrent netperf -t TCP_SENFILE

Same page might be mapped more than 100 times, more than 10000 times in
some cases.
