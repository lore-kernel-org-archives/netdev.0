From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: Re: [PATCH 11/13] net: dsa: lan9303: Added "alr_dump" sysfs port
 attribute
Date: Tue, 25 Jul 2017 10:36:06 +0200
Message-ID: <5efaa5f5-851b-418d-173b-837daa41307c@zenitel.com>
References: <f69ce739a3aa42e9b1e03fc699282b3c@nooslMX1.zenitelcss.com>
 <e5a1cefd-1e26-3a24-2928-3fd7d970d8a6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <corbet@lwn.net>,
        <andrew@lunn.ch>, <vivien.didelot@savoirfairelinux.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e5a1cefd-1e26-3a24-2928-3fd7d970d8a6@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 24. juli 2017 18:54, Florian Fainelli wrote:
> On 07/20/2017 01:49 AM, Egil Hjelmeland wrote:
>> Added read only file /sys/class/net/<port>/lan9303/alr_dump,
>> that output 168 first ALR entires.
>>
>> Currently "bridge fdb show" does not include the CPU port, while
>> "alr_dump" list all three ports per entry.
> 
> Agreed, and this is a limitation we would probably want to remove in the
> future, but duplicating what already exists with "bridge fdb show" into
> a sysfs node is a non-starter.

OK, I will keep this for my self then.

Egil


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
