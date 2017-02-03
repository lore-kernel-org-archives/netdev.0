From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Subject: Re: [PATCH v2 2/2] net: ethernet: bgmac: mac address change bug
Date: Fri, 3 Feb 2017 22:44:50 +0100
Message-ID: <43694eda-e7fd-0df5-6bec-147770e04d5c@milecki.pl>
References: <1486156133-5639-1-git-send-email-jon.mason@broadcom.com>
 <1486156133-5639-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Hari Vyas <hariv@broadcom.com>
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486156133-5639-3-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/03/2017 10:08 PM, Jon Mason wrote:
> From: Hari Vyas <hariv@broadcom.com>
>
> ndo_set_mac_address() passes struct sockaddr * as 2nd parameter to
> bgmac_set_mac_address() but code assumed u8 *.  This caused two bytes
> chopping and the wrong mac address was configured.
>
> Signed-off-by: Hari Vyas <hariv@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 4e209001b86 ("bgmac: write mac address to hardware in ndo_set_mac_address")

I think you were going to Cc stable?
