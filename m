From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: Re: [PATCH v5 6/6] 6lowpan: Fix IID format for Bluetooth
Date: Tue, 28 Feb 2017 11:13:28 +0200
Message-ID: <1488273208.3344.1.camel@linux.intel.com>
References: <20170224121440.32269-1-luiz.dentz@gmail.com>
         <20170224121440.32269-7-luiz.dentz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: patrik.flykt@linux.intel.com, stefan@osg.samsung.com,
        aar@pengutronix.de, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org
To: Luiz Augusto von Dentz <luiz.dentz@gmail.com>,
        linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4933 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751026AbdB1JP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Feb 2017 04:15:57 -0500
In-Reply-To: <20170224121440.32269-7-luiz.dentz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Luiz,

On Fri, 2017-02-24 at 14:14 +0200, Luiz Augusto von Dentz wrote:
> From: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> 
> Accourding to RFC 7668 U/L bit shall not be used:
> 
> https://wiki.tools.ietf.org/html/rfc7668#section-3.2.2 [Page 10]:
> 
>    In the figure, letter 'b' represents a bit from the
>    Bluetooth device address, copied as is without any changes on any
>    bit.  This means that no bit in the IID indicates whether the
>    underlying Bluetooth device address is public or random.
> 
>    |0              1|1              3|3              4|4             
>  6|
>    |0              5|6              1|2              7|8             
>  3|
>    +----------------+----------------+----------------+------------
> ----+
>    |bbbbbbbbbbbbbbbb|bbbbbbbb11111111|11111110bbbbbbbb|bbbbbbbbbbbbbb
> bb|
>    +----------------+----------------+----------------+------------
> ----+
> 
> Because of this the code cannot figure out the address type from the
> IP
> address anymore thus it makes no sense to use peer_lookup_ba as it
> needs
> the peer address type.
> 
> Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz@intel.com>
> ---
>  include/net/6lowpan.h   |  4 ---
> 

Looks good.

Acked-by: Jukka Rissanen <jukka.rissanen@linux.intel.com>


Cheers,
Jukka
