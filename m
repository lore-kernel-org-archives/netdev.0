From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Thu, 20 Oct 2016 15:42:21 -0700
Message-ID: <bd2fa038-2d0a-8cd1-d80d-860a7497bdf5@gmail.com>
References: <20161021092710.1b56a35b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36707 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751970AbcJTWma (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 18:42:30 -0400
In-Reply-To: <20161021092710.1b56a35b@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2016 03:27 PM, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the net tree, today's linux-next build (arm
> multi_v7_defconfig) failed like this:
> 
> ERROR: "kexec_in_progress" [drivers/net/dsa/bcm_sf2.ko] undefined!
> 
> Caused by commit
> 
>   2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")
> 
> I used the version of the net tree from next-20161020 for today.

OK, seems like we need an ifdef CONFIG_KEXEC_CORE, let me fix that.
Thanks Stephen!
-- 
Florian
