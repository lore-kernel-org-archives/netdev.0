From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: xt_TPROXY.c:undefined reference to `udp6_lib_lookup'
Date: Fri, 28 Mar 2014 20:24:15 +0800
Message-ID: <20140328122415.GA7778@localhost>
References: <5335381f.hAg4XjgCrcKXOEa4%fengguang.wu@intel.com>
 <CA+a=Yy67-y6P9RFZzx21C6LOxWrX8kpMgE9umERseZWCKXJ+RA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Dilger <andreas.dilger@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"kbuild-all@01.org" <kbuild-all@01.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Peng Tao <bergwolf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55373 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140AbaC1MYS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 08:24:18 -0400
Content-Disposition: inline
In-Reply-To: <CA+a=Yy67-y6P9RFZzx21C6LOxWrX8kpMgE9umERseZWCKXJ+RA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peng,

On Fri, Mar 28, 2014 at 05:30:12PM +0800, Peng Tao wrote:
> On Fri, Mar 28, 2014 at 4:51 PM, kbuild test robot
> <fengguang.wu@intel.com> wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   f217c44ebd41ce7369d2df07622b2839479183b0
> > commit: 2c185ffa270a95e3699c223a0ee67f560ec0db8c staging/lustre: don't compile procfs code when CONFIG_PROC_FS is off
> > date:   4 months ago
> > config: i386-randconfig-c1-03281459 (attached as .config)
> >
> > All error/warnings:
> >
> >    net/built-in.o: In function `tproxy_tg6_v1':
> >>> xt_TPROXY.c:(.text+0x44b23): undefined reference to `udp6_lib_lookup'
> >>> xt_TPROXY.c:(.text+0x44f6f): undefined reference to `udp6_lib_lookup'
> >>> xt_TPROXY.c:(.text+0x4505e): undefined reference to `udp6_lib_lookup'
> >    net/built-in.o: In function `tproxy_tg_init':
> >    xt_TPROXY.c:(.init.text+0x1748): undefined reference to `nf_defrag_ipv6_enable'
> >
> I don't see how this relates to a Lustre commit.
> .config looks reasonable to me. It has CONFIG_IPV6=m, which should
> have built udp6_lib_lookup (net/ipv6/udp.c) yet ld failed to link it?

Yes, sorry. It's your build fix unveils this link error and confused
the bisect.. I'll fixup the script to show a notice message in this case.

Thanks,
Fengguang
