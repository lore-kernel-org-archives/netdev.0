From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next:master 98/98]
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to
 restricted __be16
Date: Fri, 30 Nov 2012 13:53:56 -0800
Message-ID: <20121130135356.41a0f855@nehalam.linuxnetplumber.net>
References: <50b91efa.B0WbOtcWMs7eOSaC%fengguang.wu@intel.com>
	<50B92A6D.8000600@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kbuild test robot <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34478 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838Ab2K3VzJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 16:55:09 -0500
In-Reply-To: <50B92A6D.8000600@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Nov 2012 16:51:41 -0500
Andrew Gallatin <gallatin@myri.com> wrote:

> On 11/30/12 16:02, kbuild test robot wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> > head:   1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2
> > commit: 1b4c44e6369dbbafd113f1e00b406f1eda5ab5b2 [98/98] myri10ge: Add vlan rx for better GRO perf.
> > 
> > 
> > sparse warnings:
> > 
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:34: sparse: cast to restricted __be16
> > + drivers/net/ethernet/myricom/myri10ge/myri10ge.c:1286:16: sparse: restricted __be16 degrades to integer
> 
> 
> OK, maybe a dumb question again, but how do I get sparse to produce
> the 'cast to restricted' warnings?  I ran sparse before submission,
> but it only showed the pre-existing, non "cast to restricted"
> warnings, so I did not know I was introducing a new warning.
> Do I need to use a different architecture? (I was using x86_64).

See Documentation/sparse.txt
  
  The optional make variable CF can be used to pass arguments to sparse.  The
  build system passes -Wbitwise to sparse automatically.  To perform endianness
  checks, you may define __CHECK_ENDIAN__:

        make C=2 CF="-D__CHECK_ENDIAN__"

  These checks are disabled by default as they generate a host of warnings.
