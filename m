From: Joe Perches <joe@perches.com>
Subject: Re: [E1000-devel] [PATCH 0/4] i40e: Neatening and object size
 reductions
Date: Tue, 03 Sep 2013 21:31:29 -0700
Message-ID: <1378269089.7347.59.camel@joe-AO722>
References: <cover.1377903831.git.joe@perches.com>
	 <FC41C24E35F18A40888AACA1A36F3E416C61C0E5@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E416C61C0E5@FMSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-09-04 at 01:00 +000, Nelson, Shannon wrote:
> we hadn't noticed the new experimental "--fix" option before.  There
> are a lot of good suggestions there, but obviously it needs a lot of
> reading and tweaking before it can be used.

Yes, I think --fix works best on patches.

When you use -f and --fix together, it can do inappropriate things.

Using multiple passes of -f --fix --types=<ONE_SPECIFIC_TYPE> and
changing the "ONE_SPECIFIC_TYPE" can produce more reasonable patch
sequences.

If you do try it, and please remember it is experimental, do let me
know how well it works or doesn't work for you all.

Bug reports (and patches) welcome.

cheers, Joe
