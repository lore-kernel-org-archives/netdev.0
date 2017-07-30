From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] ethtool: support for forward error
 correction mode setting on a link
Date: Sat, 29 Jul 2017 23:24:04 -0700 (PDT)
Message-ID: <20170729.232404.59056988159960653.davem@davemloft.net>
References: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
        vidya.chowdary@gmail.com, dustin@cumulusnetworks.com,
        olson@cumulusnetworks.com, leedom@chelsio.com, kubakici@wp.pl,
        galp@mellanox.com, andrew@lunn.ch, manojmalviya@chelsio.com,
        santosh@chelsio.com, yuval.mintz@qlogic.com, odedw@mellanox.com,
        ariela@mellanox.com, jeffrey.t.kirsher@intel.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750939AbdG3GYM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 02:24:12 -0400
In-Reply-To: <1501199248-24695-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Thu, 27 Jul 2017 16:47:25 -0700

> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> Forward Error Correction (FEC) modes i.e Base-R
> and Reed-Solomon modes are introduced in 25G/40G/100G standards
> for providing good BER at high speeds. Various networking devices
> which support 25G/40G/100G provides ability to manage supported FEC
> modes and the lack of FEC encoding control and reporting today is a
> source for interoperability issues for many vendors.
> FEC capability as well as specific FEC mode i.e. Base-R
> or RS modes can be requested or advertised through bits D44:47 of base link
> codeword.
> 
> This patch set intends to provide option under ethtool to manage and
> report FEC encoding settings for networking devices as per IEEE 802.3
> bj, bm and by specs.
> 
> v2 :
>         - minor patch format fixes and typos pointed out by Andrew
>         - there was a pending discussion on the use of 'auto' vs
>           'automatic' for fec settings. I have left it as 'auto'
>           because in most cases today auto is used in place of
>           automatic to represent automatically generated values.
>           We use it in other networking config too. I would prefer
>           leaving it as auto.

Series applied to net-next, thank you.
