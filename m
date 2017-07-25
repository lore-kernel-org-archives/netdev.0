From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 10/10] bnxt_en: add support for port_attr_get
 and and get_phys_port_name
Date: Mon, 24 Jul 2017 21:06:17 -0700
Message-ID: <20170724210617.651cd495@cakuba.netronome.com>
References: <1500914069-15724-11-git-send-email-michael.chan@broadcom.com>
        <201707251020.bDXHsX68%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
        Sathya Perla <sathya.perla@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:28837 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751196AbdGYEGZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Jul 2017 00:06:25 -0400
In-Reply-To: <201707251020.bDXHsX68%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Jul 2017 10:44:49 +0800, kbuild test robot wrote:
>    drivers/net/ethernet/broadcom/bnxt/bnxt.c: In function 'bnxt_init_one':
> >> drivers/net/ethernet/broadcom/bnxt/bnxt.c:7897:5: error: 'struct net_device' has no member named 'switchdev_ops'; did you mean 'netdev_ops'?  
>      dev->switchdev_ops = &bnxt_switchdev_ops;
>         ^~

Check out SWITCHDEV_SET_OPS() from commit d643a75ac2bc ("net: switchdev:
add SET_SWITCHDEV_OPS helper").
