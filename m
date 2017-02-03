From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/2] net: ethernet: bgmac: mac address change bug
Date: Fri, 3 Feb 2017 13:49:32 -0800
Message-ID: <98cd2c6a-8bd9-39c7-0288-ce84130627b5@gmail.com>
References: <1486156133-5639-1-git-send-email-jon.mason@broadcom.com>
 <1486156133-5639-3-git-send-email-jon.mason@broadcom.com>
 <43694eda-e7fd-0df5-6bec-147770e04d5c@milecki.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Hari Vyas <hariv@broadcom.com>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <43694eda-e7fd-0df5-6bec-147770e04d5c@milecki.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/2017 01:44 PM, Rafał Miłecki wrote:
> On 02/03/2017 10:08 PM, Jon Mason wrote:
>> From: Hari Vyas <hariv@broadcom.com>
>>
>> ndo_set_mac_address() passes struct sockaddr * as 2nd parameter to
>> bgmac_set_mac_address() but code assumed u8 *.  This caused two bytes
>> chopping and the wrong mac address was configured.
>>
>> Signed-off-by: Hari Vyas <hariv@broadcom.com>
>> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
>> Fixes: 4e209001b86 ("bgmac: write mac address to hardware in
>> ndo_set_mac_address")
> 
> I think you were going to Cc stable?

David takes care of queueing patches for -stable trees:

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/netdev-FAQ.txt#n114
-- 
Florian
