From: Mike Looijmans <mike.looijmans@topic.nl>
Subject: Re: [PATCH] phy: micrel.c: Support ksz9031 energy-detect power-down
 mode
Date: Mon, 3 Oct 2016 18:30:17 +0200
Message-ID: <57F28799.7030701@topic.nl>
References: <1475499870-11465-1-git-send-email-mike.looijmans@topic.nl>
 <20161003143508.GA26382@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, f.fainelli@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161003143508.GA26382@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03-10-16 16:35, Andrew Lunn wrote:
>> +    Boolean:
>> +
>> +      - enable-edpd : Not related to timing. Specify this property to enable
>> +                      energy-detect power-down mode in the PHY.
>
> The Broadcom PHYs unconditionally enable this feature.
>
> The SMSC driver has an option: smsc,disable-energy-detect because it
> seems to have a rare hardware bug when it is enabled.
>
> And you would like to make it off by default.
>
> Could we avoid having three drivers doing three different things?
> Could you have it unconditionally on, and see if anybody reports it
> being broken?

Good suggestion I think. It's a feature found on many PHYs, apparently 
without any ill effects, so just enabling unconditionally simplifies 
things. And it's good for the environment...

I'll post a v2 patch (which won't need devicetree changes then).

-- 
Mike Looijmans
