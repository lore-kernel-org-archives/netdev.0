From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Fri, 21 Apr 2017 14:12:24 -0400 (EDT)
Message-ID: <20170421.141224.1507476820517003604.davem@davemloft.net>
References: <BL2PR07MB23064C036E994DC63475F7388D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420.112021.167483274923043370.davem@davemloft.net>
        <AAEA33E297BCAC4B9BB20A7C2DF0AB8D80551D1A@FMSMSX113.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, gerlitz.or@gmail.com,
        jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36334 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041718AbdDUSWb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:22:31 -0400
In-Reply-To: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D80551D1A@FMSMSX113.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Date: Thu, 20 Apr 2017 22:25:03 +0000

> I'm not adding backdoor hooks to do naughty things, I'm just (very
> slightly) enhancing what's already there.

I'm not going to drop this series because of this.

I'm just sounding the warning that I probably have to start pushing
back harder in the future because seriously.. debugfs is not deployed
production and in fact a lot of people disable it for security
reasons.

Even tracing got out of debugfs for this reason.
