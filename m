From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 16/20] net: dsa: move notifier info to private
 header
Date: Mon, 22 May 2017 12:37:00 -0700
Message-ID: <b5e13d45-e7e6-113c-de78-cb0f151c726f@gmail.com>
References: <20170519210055.9366-1-vivien.didelot@savoirfairelinux.com>
 <20170519210055.9366-17-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36260 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761140AbdEVThE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 15:37:04 -0400
In-Reply-To: <20170519210055.9366-17-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 02:00 PM, Vivien Didelot wrote:
> The DSA notifier events and info structure definitions are not meant for
> DSA drivers and users, but only used internally by the DSA core files.
> 
> Move them from the public net/dsa.h file to the private dsa_priv.h file.
> 
> Also use this opportunity to turn the events into an anonymous enum,
> because we don't care about the values, and this will prevent future
> conflicts when adding (and sorting) new events.

LGTM

> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
