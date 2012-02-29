From: Joe Perches <joe@perches.com>
Subject: RE: coding style issues -- [davem@davemloft.net: Re: pull request:
 wireless-next 2012-02-06]
Date: Wed, 29 Feb 2012 11:13:31 -0800
Message-ID: <1330542811.21491.7.camel@joe2Laptop>
References: <20120229173421.GA13733@tuxdriver.com>
	 <477F20668A386D41ADCC57781B1F70430836762D55@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Ilan Elias <ilane@ti.com>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Amitkumar Karwar <akarwar@marvell.com>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Bing Zhao <bzhao@marvell.com>, Kalle Valo <kvalo@qca.qualcomm.com>,
	Andy Whitcroft <apw@shadowen.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <477F20668A386D41ADCC57781B1F70430836762D55@SC-VEXCH1.marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-29 at 10:57 -0800, Bing Zhao wrote:
> Joe Perches submitted a patch "[PATCH v2] checkpatch: Add some --strict coding style checks"
> I have applied Joe's patch to my local git tree.
> 
> All new patches will follow Dave's rules and be checked with --strict option.
> Furthermore, we will have a series of cleanup patches to address the coding style issues in existing code.

Hi Bing.

There's an issue with the checkpatch patch.
It doesn't always work correctly when there
are consecutive parenthesis.

Kalle Valo showed an example that fails:

	if (!IS_ALIGNED((unsigned long) skb->data - HTC_HDR_LENGTH, 4) &&
	    skb_cloned(skb)) {

I have a tentative fix here, but I'm waiting on
Andy Whitcroft to give some guidance on how best
to fix it given a minimum perl version of 5.10.

The proposed patch doesn't work with perl versions
less than 5.10 and there is at least one person
that still uses 5.8.
