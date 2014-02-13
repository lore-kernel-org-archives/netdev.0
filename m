From: Dave Jones <davej@redhat.com>
Subject: Re: 3.14-mw regression: rtl8169 WARNING: DMA-API: exceeded 7
 overlapping mappings of pfn 55ebe
Date: Thu, 13 Feb 2014 15:16:28 -0500
Message-ID: <20140213201628.GA26303@redhat.com>
References: <1859471893.20140126115521@eikelenboom.it>
 <20140127000305.GA14236@electric-eye.fr.zoreil.com>
 <CAA9_cme2hgJ=jCDkPh5n5RP8fiJE-dVwbFr-apKv1=mNGPHYZg@mail.gmail.com>
 <84816226.20140206123631@eikelenboom.it>
 <942972114.20140206140909@eikelenboom.it>
 <CAPcyv4g2EnCLFWfLfSDnjtwrid2tCq2k6wh-8sPYY06eJpM83A@mail.gmail.com>
 <1434499348.20140211205617@eikelenboom.it>
 <CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAPcyv4juAS0ODRPKE-_wXYu5bixLnvsgs3jgo4vzWcatfnyVsw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 11, 2014 at 06:07:10PM -0800, Dan Williams wrote:

 > The overlap granularity is too large.  Multiple dma_map_single
 > mappings are allowed to a given page as long as they don't collide on
 > the same cache line.
 > 
 > 
 > Please try the attached patch to see if it fixes this issue.  Works ok for me.

FWIW, since applying this, I haven't seen the 8169 warnings.

thanks,

	Dave
