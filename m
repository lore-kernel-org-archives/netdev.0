From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2 net-next 1/2] net: dsa: lan9303: Add port_fast_age and port_fdb_dump methods
Date: Thu, 19 Oct 2017 11:12:55 -0400
Message-ID: <871slzmars.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <20171019121015.7395-1-privat@egil-hjelmeland.no> <20171019121015.7395-2-privat@egil-hjelmeland.no> <87mv4nw869.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me> <1976baec-5ec3-9ec4-252b-743d9f1d9579@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain
To: Egil Hjelmeland <privat@egil-hjelmeland.no>, andrew@lunn.ch,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:59126 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752135AbdJSPM6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 11:12:58 -0400
In-Reply-To: <1976baec-5ec3-9ec4-252b-743d9f1d9579@egil-hjelmeland.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Egil,

Egil Hjelmeland <privat@egil-hjelmeland.no> writes:

>>>   #define LAN9303_MAC_RX_CFG_2 0x0c01
>>>   #define LAN9303_MAC_TX_CFG_2 0x0c40
>>>   #define LAN9303_SWE_ALR_CMD 0x1800
>>> +# define ALR_CMD_MAKE_ENTRY    BIT(2)
>>> +# define ALR_CMD_GET_FIRST     BIT(1)
>>> +# define ALR_CMD_GET_NEXT      BIT(0)
>>> +#define LAN9303_SWE_ALR_WR_DAT_0 0x1801
>>> +#define LAN9303_SWE_ALR_WR_DAT_1 0x1802
>>> +# define ALR_DAT1_VALID        BIT(26)
>>> +# define ALR_DAT1_END_OF_TABL  BIT(25)
>>> +# define ALR_DAT1_AGE_OVERRID  BIT(25)
>>> +# define ALR_DAT1_STATIC       BIT(24)
>>> +# define ALR_DAT1_PORT_BITOFFS  16
>>> +# define ALR_DAT1_PORT_MASK    (7 << ALR_DAT1_PORT_BITOFFS)
>>> +#define LAN9303_SWE_ALR_RD_DAT_0 0x1805
>>> +#define LAN9303_SWE_ALR_RD_DAT_1 0x1806
>>> +#define LAN9303_SWE_ALR_CMD_STS 0x1808
>>> +# define ALR_STS_MAKE_PEND     BIT(0)
>> 
>> Why is there different spacing and prefix with these defines?
>
> The extra space is to set bit definitions apart from register offsets,
> a convention that is used in the file. However, agree that the
> bit defs should be prefixed with LAN9303_ to be consistent with
> rest of the file.

OK, I'm fine with this spacing then. The prefix would be nice though,
thanks!

>>> +/* --------------------- Various chip setup ----------------------*/
>>> +
>> 
>> This isn't a very useful comment, at least use an inline or block
>> comment if you want to keep it.
>> 
>
> I put it to signify the end of the ALR section. But could not think of a
> better text... Perhaps "End of ALR functions" would be better?
> Or perhaps I should just drop the "section comments"? After all the
> functions in question has "alr" in their names.

If you cannot think about a comment text which brings value, it
certainly means it isn't necessary. As you said the implicit "alr"
namespace already helps here. I'd personally drop all section comments
;-)

A general thought against comments is that namespaced and readable code
must act as its own documentation. Explicit comments are only necessary
and appreciated for complex portion of code, for example when
performance is chosen over readability.


Thank you,

      Vivien
