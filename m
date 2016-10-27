From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] rocker: set physical device for port netdevice
Date: Thu, 27 Oct 2016 22:26:12 +0200
Message-ID: <20161027202612.GA1752@nanopsycho>
References: <1477571469-14818-1-git-send-email-jiri@resnulli.us>
 <201610280444.f8Gzv3LA%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33936 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964821AbcJ0U0P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:26:15 -0400
Received: by mail-wm0-f67.google.com with SMTP id y138so4382908wme.1
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 13:26:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <201610280444.f8Gzv3LA%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Oct 27, 2016 at 10:03:46PM CEST, lkp@intel.com wrote:
>Hi Jiri,
>
>[auto build test WARNING on net-next/master]
>
>url:    https://github.com/0day-ci/linux/commits/Jiri-Pirko/rocker-set-physical-device-for-port-netdevice/20161028-030044
>config: tile-allmodconfig (attached as .config)
>compiler: tilegx-linux-gcc (GCC) 4.6.2
>reproduce:
>        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>        chmod +x ~/bin/make.cross
>        # save the attached .config to linux build tree
>        make.cross ARCH=tile 
>
>All warnings (new ones prefixed by >>):
>
>   drivers/net/ethernet/rocker/rocker_main.c: In function 'rocker_probe_port':
>>> drivers/net/ethernet/rocker/rocker_main.c:2545:2: warning: assignment discards 'const' qualifier from pointer target type [enabled by default]
>

Sigh, sending v2. 
