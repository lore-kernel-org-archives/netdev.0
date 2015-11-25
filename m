From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 06/16] i40e: Properly cast type for arithmetic
Date: Wed, 25 Nov 2015 02:58:22 -0800
Message-ID: <1448449102.20113.28.camel@perches.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448409886-90686-7-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448412212.20113.12.camel@perches.com>
	 <1448448411.3154.32.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0186.hostedemail.com ([216.40.44.186]:36400 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751710AbbKYK60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 05:58:26 -0500
In-Reply-To: <1448448411.3154.32.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-25 at 02:46 -0800, Jeff Kirsher wrote:
> On Tue, 2015-11-24 at 16:43 -0800, Joe Perches wrote:
> > On Tue, 2015-11-24 at 16:04 -0800, Jeff Kirsher wrote:
> > > From: Helin Zhang <helin.zhang@intel.com>
> > > 
> > > Pointer of type void * shouldn't be used in arithmetic, which may
> > > result in compilation error. Casting of (u8 *) can be added to fix
> > > that.
> > > 
> > 
> > void * arithmetic is used quite frequently in the kernel.
> > 
> > What compiler emits an error?
> 
> When you use the gcc -Wpointer-arith, it generates the warning.

make W=3 does that

$ make help
[...]
make W=n   [targets] Enable extra gcc checks, n=1,2,3 where
		1: warnings which may be relevant and do not occur too often
		2: warnings which occur quite often but may still be relevant
		3: more obscure warnings, can most likely be ignored

but I think it should be ignored.
