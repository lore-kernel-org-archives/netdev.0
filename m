From: Rafa Corvillo <rafael.corvillo@aoifes.com>
Subject: Re: [ISSUE: sky2 - rx error] Link stops working under heavy traffic
 load connected to a mv88e6176
Date: Tue, 16 May 2017 18:19:09 +0200
Message-ID: <591B267D.1030800@aoifes.com>
References: <20170427130450.GL17172@lunn.ch> <59032D8B.1010801@aoifes.com>
 <20170428122259.GH13231@lunn.ch> <59105EA3.9030203@aoifes.com>
 <20170508123852.GI27709@lunn.ch> <591AD990.901@aoifes.com>
 <20170516124759.GB27959@lunn.ch> <591AF9FD.1000304@aoifes.com>
 <20170516132116.GE5456@lunn.ch> <591B1FC2.1090402@aoifes.com>
 <20170516155843.GE32357@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-relay-00-3.dondominio.net ([31.214.176.16]:36885 "EHLO
        smtp-relay-00-3.dondominio.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750950AbdEPQTM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:19:12 -0400
In-Reply-To: <20170516155843.GE32357@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Also, check that in sky2_rx_add(), le->length is set to 4K.
>>>
>>
>> The value of le->length is set to 1520.
>
>> Rafa
>
> Ah.
>
> You probably need to change sky2_get_rx_data_size() as well, to add in
> the extra 8 bytes.
>
>      Andrew
>

If I add the extra 8 byte in the function sky2_get_rx_data_size(), the 
value of le->length is set to 1528. But the rx error still appears. 
Because of that, I think it is possible the maximum length could be set 
outside the sky2 code.

Rafa
