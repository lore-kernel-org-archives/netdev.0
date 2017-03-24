From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [net-next:master 566/583] warning: (NET_DSA_BCM_SF2) selects
 MDIO_BCM_UNIMAC which has unmet direct dependencies (NETDEVICES && ..)
Date: Fri, 24 Mar 2017 14:52:12 -0700
Message-ID: <b2148217-ed2b-183b-619b-13721c54aaec@gmail.com>
References: <201703250548.GadDgacp%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34159 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933123AbdCXVwS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 17:52:18 -0400
Received: by mail-wm0-f66.google.com with SMTP id u132so542056wmg.1
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 14:52:17 -0700 (PDT)
In-Reply-To: <201703250548.GadDgacp%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/24/2017 02:47 PM, kbuild test robot wrote:
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   ff41c7fa64854cc95a472d43af82c17c043aa757
> commit: 90eff9096c01ba90cdae504a6b95ee87fe2556a3 [566/583] net: phy: Allow splitting MDIO bus/device support from PHYs
> config: x86_64-randconfig-x009-201712 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         git checkout 90eff9096c01ba90cdae504a6b95ee87fe2556a3
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
> warning: (NET_DSA_BCM_SF2) selects MDIO_BCM_UNIMAC which has unmet direct dependencies (NETDEVICES && MDIO_DEVICE && HAS_IOMEM && OF_MDIO)

Humm yes indeed. Thanks!
-- 
Florian
