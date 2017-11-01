From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc-testing: split config file
Date: Wed, 01 Nov 2017 11:06:23 +0900 (KST)
Message-ID: <20171101.110623.348780136039045689.davem@davemloft.net>
References: <20171031182728.9725-1-bjb@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        chrism@mellanox.com, lucasb@mojatatu.com, aring@mojatatu.com,
        mrv@mojatatu.com, netdev@vger.kernel.org
To: bjb@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43694 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACG1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:06:27 -0400
In-Reply-To: <20171031182728.9725-1-bjb@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brenda J. Butler" <bjb@mojatatu.com>
Date: Tue, 31 Oct 2017 14:27:28 -0400

> Move the config customization into a site-local file
> tdc_config_local.py, so that updates of the tdc test
> software does not require hand-editing of the config.
> This patch includes a template for the site-local
> customization file.
> 
> In addition, this makes it easy to revert to a stock
> tdc environment for testing the test framework and/or
> the core tests.
> 
> Also it makes it harder for any custom config to be
> submitted back to the kernel tdc.
> 
> Signed-off-by: Brenda J. Butler <bjb@mojatatu.com>

Please always remove trailing empty lines in files, GIT even warns
about this when one tries to apply the patch:

> @@ -17,3 +17,17 @@ NAMES = {
>            # Name of the namespace to use
>            'NS': 'tcut'
>          }
> +
 ...
> +# example adding values to ENVIR, without editing tdc_config.py
> +ENVIR['VALGRIND_LIB'] = '/usr/lib/valgrind'
> +ENVIR['VALGRIND_BIN'] = '/usr/bin/valgrind'
> +ENVIR['VGDB_BIN'] = '/usr/bin/vgdb'
> +

I fixed it up this time, but please be mindful of this in the future.

Thanks.
