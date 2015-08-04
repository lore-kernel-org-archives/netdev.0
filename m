From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH] net: dsa: fix EDSA frame from hwaccel frame
Date: Tue, 4 Aug 2015 02:01:18 -0400 (EDT)
Message-ID: <693647000.2315.1438668078706.JavaMail.zimbra@savoirfairelinux.com>
References: <1438566362-28786-1-git-send-email-vivien.didelot@savoirfairelinux.com> <20150803.222159.1711458384701896079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	Guenter Roeck <linux@roeck-us.net>, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: David <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150803.222159.1711458384701896079.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Aug 4, 2015, at 1:21 AM, David davem@davemloft.net wrote:

> From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> Date: Sun,  2 Aug 2015 21:46:02 -0400
> 
>> If the underlying network device features NETIF_F_HW_VLAN_CTAG_TX,
>> an EDSA frame is prepended with a 802.1q header once queued.
>> 
>> To fix this, push the VLAN tag to the payload if present, before
>> checking the frame protocol.
>> 
>> [note: we may prefer to access directly VLAN TCI from hwaccel frames,
>> but this approach is simpler.]
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> This is a bug fix so should target 'net', but you generated the patch
> against 'net-next'.
> 
> In any event, you should be explicit about the tree you are targetting
> in order to not waste my time like this, by simply specifying the
> tree in your "[PATCH xxx]" text in your subject line.   Either
> "[PATCH net]" or "[PATCH net-next]".

Dully noted. Should I resend it?

Thanks,
-v
