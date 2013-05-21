From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v4 net-next 1/4] net: implement support for low latency
 socket polling
Date: Tue, 21 May 2013 20:28:22 +0300
Message-ID: <519BAEB6.2010206@linux.intel.com>
References: <20130521142641.18498.52856.stgit@ladj378.jer.intel.com>  <20130521142650.18498.71715.stgit@ladj378.jer.intel.com> <1369157030.2615.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dave Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369157030.2615.24.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/05/2013 20:23, Ben Hutchings wrote:
> On Tue, 2013-05-21 at 17:26 +0300, Eliezer Tamir wrote:

> Microseconds, not cycles.

> us, not ms.

> CONFIG_X86_TSC

> Should be done before testing ndo_ll_poll above, so you can avoid
> repeating the indirections.

> Typo: 'permanent'.
>
> Ben.
>
Thanks!
-Eliezer
