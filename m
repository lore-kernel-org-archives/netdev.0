From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH net-next 2/2] net: dsa: lan9303: Learn addresses on CPU
 port when bridged
Date: Wed, 25 Oct 2017 12:27:48 +0200
Message-ID: <172a64f4-fd38-c954-10cf-9d7170e4925d@egil-hjelmeland.no>
References: <20171024093515.6749-1-privat@egil-hjelmeland.no>
 <20171024093515.6749-3-privat@egil-hjelmeland.no>
 <20171024163334.GC12347@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aibo.runbox.com ([91.220.196.211]:39102 "EHLO aibo.runbox.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932210AbdJYK1z (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Oct 2017 06:27:55 -0400
In-Reply-To: <20171024163334.GC12347@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24. okt. 2017 18:33, Andrew Lunn wrote:
> On Tue, Oct 24, 2017 at 11:35:15AM +0200, Egil Hjelmeland wrote:
>> + */
>> +static inline int lan9303_tx_use_arl(struct dsa_port *dp, u8 *dest_addr)
> 
> Hi Egil
> 
> There is no need for the inline. The compiler will do that anyway, for
> a function like this. >
Will fix.

>      Andrew
> 

Thanks
Egil
