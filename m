From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 net 6/8] net: bcmgenet: Power up the internal PHY
 before probing the MII
Date: Thu, 9 Mar 2017 17:44:36 -0800
Message-ID: <23787c1d-c897-eaa5-dda5-49607ac3617d@gmail.com>
References: <20170310005850.10808-1-opendmb@gmail.com>
 <20170310005850.10808-7-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Doug Berger <opendmb@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310005850.10808-7-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 04:58 PM, Doug Berger wrote:
> When using the internal PHY it must be powered up when the MII is probed
> or the PHY will not be detected.  Since the PHY is powered up at reset
> this has not been a problem.  However, when the kernel is restarted with
> kexec the PHY will likely be powered down when the kernel starts so it
> will not be detected and the Ethernet link will not be established.
> 
> This commit explicitly powers up the internal PHY when the GENET driver
> is probed to correct this behavior.
> 
> Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
> Signed-off-by: Doug Berger <opendmb@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
