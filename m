From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 03/15] net: bcm63xx_enet: Utilize phy_ethtool_nway_reset
Date: Tue, 15 Nov 2016 12:15:35 -0800
Message-ID: <cac4f84c-e869-cba2-e505-237c2aeeb5a8@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>
 <20161115180644.3941-4-f.fainelli@gmail.com>
 <3dc4471a-1afd-0e28-1de9-60558cece143@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        "maintainer:BROADCOM BCM63XX ARM ARCHITECTURE"
        <bcm-kernel-feedback-list@broadcom.com>,
        Arnd Bergmann <arnd@arndb.de>,
        "xypron.glpk@gmx.de" <xypron.glpk@gmx.de>,
        Jarod Wilson <jarod@redhat.com>,
        Thierry Reding <treding@nvidia.com>,
        "moderated list:BROADCOM BCM63XX ARM ARCHITECTURE"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Heinrich Schuchardt <xypron.debian@gmx.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3dc4471a-1afd-0e28-1de9-60558cece143@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/2016 11:59 AM, Heinrich Schuchardt wrote:
> On 11/15/2016 07:06 PM, Florian Fainelli wrote:
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Each patch of your patch series should have a commit message.

It's pretty obvious what this does, really.

> 
> You can add the missing commit messages with
> git rebase -i HEAD~15
> choosing reword.
> 
> Please, add a cover letter message describing the patch series using
> 
> git format-patch -ns --cover-letter HEAD~15..HEAD
> 
> and provide a summary in the 0/15 message.

I did:

https://www.mail-archive.com/netdev@vger.kernel.org/maillist.html

and that is also apparent from:

In-Reply-To: <20161115180644.3941-1-f.fainelli@gmail.com>
References: <20161115180644.3941-1-f.fainelli@gmail.com>

And what I also did is to intentionally make sure that for each patch,
there would not be 50+ people CC'd, but just the relevant people for
each driver, which is exactly how cc-cmd=scripts/get_maintainer.pl work,
making my life simpler honestly.

It's not nearly my first patch submission, but I admit I have been semi
intentionally lazy with this patch set considering the number of patches.

Anyway, enough time wasted on this.
-- 
Florian
