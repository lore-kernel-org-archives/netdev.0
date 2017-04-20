From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/14] i40e: dump VF information in debugfs
Date: Thu, 20 Apr 2017 16:54:51 -0400 (EDT)
Message-ID: <20170420.165451.2187580822981568025.davem@davemloft.net>
References: <BL2PR07MB23064B547F325DD002E513FC8D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
        <20170420.163548.662307112452546016.davem@davemloft.net>
        <BL2PR07MB230655E4217E619BABCA54D18D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, gerlitz.or@gmail.com,
        jeffrey.t.kirsher@intel.com, mitch.a.williams@intel.com,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Chad.Dupuis@cavium.com,
        Manish.Rangankar@cavium.com
To: Yuval.Mintz@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034114AbdDTUyy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 16:54:54 -0400
In-Reply-To: <BL2PR07MB230655E4217E619BABCA54D18D1B0@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Date: Thu, 20 Apr 2017 20:50:55 +0000

> Nope, I don't mind doing the work. What I would appreciate is some
> constructive suggestions on a seemingly feasible approach that might work.
> I feel like I've been bashed enough for one day. :-)

Well, it seems like the thing that you want to do is pull items out of
an object.  Start with that as an abstraction and see where it goes.
