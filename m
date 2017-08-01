From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: Re: [PATCH v2 net-next 2/3] net: dsa: lan9303: define
 LAN9303_NUM_PORTS 3
Date: Tue, 1 Aug 2017 14:31:44 +0200
Message-ID: <10b6b9fc-d2f9-1761-802f-724d9f6b3df1@egil-hjelmeland.no>
References: <20170801111439.1143-1-privat@egil-hjelmeland.no>
 <20170801111439.1143-3-privat@egil-hjelmeland.no>
 <201708011349.52529.jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Juergen Borleis <jbe@pengutronix.de>, kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201708011349.52529.jbe@pengutronix.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01. aug. 2017 13:49, Juergen Borleis wrote:
> Hi Egil,
> 
> On Tuesday 01 August 2017 13:14:38 Egil Hjelmeland wrote:
>> Will be used instead of '3' in upcomming patches.
>>
>>
>> +#define LAN9303_NUM_PORTS 3
>> +
> 
> Maybe we should put this macro into a shared location because
> in "net/dsa/tag_lan9303.c" there is already a "#define LAN9303_MAX_PORTS
> 3".
> 
> jb
> 

Is there any suitable shared location for such driver specific
definitions?
I could change the name to LAN9303_MAX_PORTS so it the same.
Rhymes better with DSA_MAX_PORTS too.

Let's hear what other mean.

Egil
