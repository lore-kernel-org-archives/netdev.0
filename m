From: Tariq Toukan <tariqt@mellanox.com>
Subject: RXFH manual configuration
Date: Sun, 18 Jun 2017 11:32:10 +0300
Message-ID: <f78d2a7c-3dc1-009c-9b06-37ed8e87090e@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Jacob Keller <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0051.outbound.protection.outlook.com ([104.47.0.51]:5856
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750968AbdFRIcS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 04:32:18 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jacob,

I am looking at your patch:
d4ab4286276f ethtool: correctly ensure {GS}CHANNELS doesn't conflict ...

I wonder - if I want to configure the number of channels (ethtool -L), 
without being aware to the history of indirection table (manually set or 
not), how can I know what is the expected behavior?
I should be able, from userspace, to query the value of 
netif_is_rxfh_configured() in order to decide whether the outcome of an 
ethtool -L command is correct or not.

Do you know if this indication exists?

Thanks,
Tariq
