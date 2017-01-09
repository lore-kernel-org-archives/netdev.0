From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH net-next] net: dsa: select NET_SWITCHDEV
Date: Sun, 8 Jan 2017 17:32:00 -0800
Message-ID: <336a46c0-705a-9cf0-1a0d-447af28893bb@infradead.org>
References: <20170108231724.27398-1-vivien.didelot@savoirfairelinux.com>
 <ae5c2999-98a3-1b88-dd1d-970d958f6d7a@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:43144 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965459AbdAIBcH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 20:32:07 -0500
In-Reply-To: <ae5c2999-98a3-1b88-dd1d-970d958f6d7a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/17 17:18, Florian Fainelli wrote:
> On 01/08/2017 03:17 PM, Vivien Didelot wrote:
>> DSA wraps SWITCHDEV, thus select it instead of depending on it.
>>
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> 

but when CONFIG_INET is not enabled, the patch causes this warning:

warning: (NET_DSA) selects NET_SWITCHDEV which has unmet direct dependencies (NET && INET)


-- 
~Randy
