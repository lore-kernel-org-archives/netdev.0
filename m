From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
Subject: Re: [PATCH 2/2] net: ethernet: bgmac: mac address change bug
Date: Thu, 2 Feb 2017 00:12:14 +0100
Message-ID: <bee62170-c890-bd9e-5842-7c87ff96542c@milecki.pl>
References: <1485988752-21030-1-git-send-email-jon.mason@broadcom.com>
 <1485988752-21030-3-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Hari Vyas <hariv@broadcom.com>
To: Jon Mason <jon.mason@broadcom.com>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485988752-21030-3-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/2017 11:39 PM, Jon Mason wrote:
> From: Hari Vyas <hariv@broadcom.com>
>
> ndo_set_mac_address() passes struct sockaddr * as 2nd parameter to
> bgmac_set_mac_address() but code assumed u8 *.  This caused two bytes
> chopping and the wrong mac address was configured.
>
> Signed-off-by: Hari Vyas <hariv@broadcom.com>
> Signed-off-by: Jon Mason <jon.mason@broadcom.com>
> Fixes: 4e209001b86 ("bgmac: write mac address to hardware in ndo_set_mac_address")

Sounds OK, would it make sense to Cc stable?
