From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net 3/5] l2tp: fix racy socket lookup in l2tp_ip and
 l2tp_ip6 bind()
Date: Tue, 29 Nov 2016 13:12:07 +0100
Message-ID: <20161129121206.32xn7gmrtv42s6nm@alphalink.fr>
References: <de1fbe689e143ca160dd4da9a61c585c44ff6e78.1480360512.git.g.nault@alphalink.fr>
 <201611290515.BXajf2gX%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org,
        James Chapman <jchapman@katalix.com>,
        Chris Elston <celston@katalix.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:42646 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751063AbcK2MMW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 07:12:22 -0500
Content-Disposition: inline
In-Reply-To: <201611290515.BXajf2gX%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 05:10:40AM +0800, kbuild test robot wrote:
> Hi Guillaume,
> 
> [auto build test WARNING on net/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Guillaume-Nault/l2tp-fixes-for-l2tp_ip-and-l2tp_ip6-socket-handling/20161129-043208
> config: x86_64-rhel (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
> 
> All warnings (new ones prefixed by >>):
> 
>    net/l2tp/l2tp_ip.c: In function 'l2tp_ip_bind':
> >> net/l2tp/l2tp_ip.c:299:9: warning: 'ret' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      return ret;
>             ^~~
> 
I should have seen this earlier, sorry.
This is now fixed in v2.
