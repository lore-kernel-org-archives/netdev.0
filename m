From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 09/12] net: dsa: b53: Wire-up EEE
Date: Mon, 18 Sep 2017 15:34:16 -0700
Message-ID: <77a80a64-7840-861d-a3ec-5e2efbfe0d8c@gmail.com>
References: <20170918214128.27896-1-f.fainelli@gmail.com>
 <20170918214128.27896-10-f.fainelli@gmail.com>
 <87mv5r1vzx.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35280 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750783AbdIRWeV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:34:21 -0400
Received: by mail-wr0-f196.google.com with SMTP id n64so1193338wrb.2
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:34:20 -0700 (PDT)
In-Reply-To: <87mv5r1vzx.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2017 03:29 PM, Vivien Didelot wrote:
> Hi Florian,
> 
> Florian Fainelli <f.fainelli@gmail.com> writes:
> 
>> @@ -1000,6 +1005,9 @@ static void b53_adjust_link(struct dsa_switch *ds, int port,
>>  			b53_write8(dev, B53_CTRL_PAGE, po_reg, gmii_po);
>>  		}
>>  	}
>> +
>> +	/* Re-negotiate EEE if it was enabled already */
>> +	p->eee_enabled = b53_eee_init(ds, port, phydev);
>>  }
> 
> Same here, I think we can move this up to DSA core, maybe with a
> eee_enabled mask in dsa_switch or a bool in dsa_port.

This can be done as a subsequent patch, sure.
-- 
Florian
