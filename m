From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: fix issues with fw_type module
 parameter
Date: Mon, 14 Aug 2017 22:25:38 -0700 (PDT)
Message-ID: <20170814.222538.1333131361301915174.davem@davemloft.net>
References: <20170814191756.GA1371@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50604 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751652AbdHOFZi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 01:25:38 -0400
In-Reply-To: <20170814191756.GA1371@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 14 Aug 2017 12:17:56 -0700

> From: Derek Chickles <derek.chickles@cavium.com>
> 
> The fw_type module parameter isn't showing up in the
> /sys/module/liquidio/parameters directory.  Fix it by setting the read
> permission bits for user, group, other in module_param_string().  Revise
> the description of fw_type.  Initialize the fw_type static char array with
> the default value to conform to the module parameter description.
> 
> Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
