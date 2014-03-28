From: Peng Tao <bergwolf@gmail.com>
Subject: Re: xt_TPROXY.c:undefined reference to `udp6_lib_lookup'
Date: Fri, 28 Mar 2014 17:30:12 +0800
Message-ID: <CA+a=Yy67-y6P9RFZzx21C6LOxWrX8kpMgE9umERseZWCKXJ+RA@mail.gmail.com>
References: <5335381f.hAg4XjgCrcKXOEa4%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andreas Dilger <andreas.dilger@intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"kbuild-all@01.org" <kbuild-all@01.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:41732 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153AbaC1Jad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:30:33 -0400
Received: by mail-ob0-f173.google.com with SMTP id gq1so5659479obb.4
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 02:30:32 -0700 (PDT)
In-Reply-To: <5335381f.hAg4XjgCrcKXOEa4%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2014 at 4:51 PM, kbuild test robot
<fengguang.wu@intel.com> wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   f217c44ebd41ce7369d2df07622b2839479183b0
> commit: 2c185ffa270a95e3699c223a0ee67f560ec0db8c staging/lustre: don't compile procfs code when CONFIG_PROC_FS is off
> date:   4 months ago
> config: i386-randconfig-c1-03281459 (attached as .config)
>
> All error/warnings:
>
>    net/built-in.o: In function `tproxy_tg6_v1':
>>> xt_TPROXY.c:(.text+0x44b23): undefined reference to `udp6_lib_lookup'
>>> xt_TPROXY.c:(.text+0x44f6f): undefined reference to `udp6_lib_lookup'
>>> xt_TPROXY.c:(.text+0x4505e): undefined reference to `udp6_lib_lookup'
>    net/built-in.o: In function `tproxy_tg_init':
>    xt_TPROXY.c:(.init.text+0x1748): undefined reference to `nf_defrag_ipv6_enable'
>
I don't see how this relates to a Lustre commit.
.config looks reasonable to me. It has CONFIG_IPV6=m, which should
have built udp6_lib_lookup (net/ipv6/udp.c) yet ld failed to link it?

CCing netdev to see if there is someone seeing it otherwise.

Thanks,
Tao
