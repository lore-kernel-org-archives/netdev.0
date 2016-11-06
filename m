From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: 3com: typhoon: fix typhoon_get_link_ksettings
Date: Sun, 6 Nov 2016 12:53:57 +0300
Message-ID: <37849ac5-8781-00c0-de4c-476ca69ab1bf@cogentembedded.com>
References: <1478358700-22711-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, dave@thedillows.org,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478358700-22711-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/5/2016 6:11 PM, Philippe Reynes wrote:

> When moving from typhoon_get_settings to typhoon_getlink_ksettings
> in the commit commit f7a5537cd2a5 ("net: 3com: typhoon: use new api

    One "commit" is enough. :-)

> ethtool_{get|set}_link_ksettings"), we use a local variable supported
> but we forgot to update the struct ethtool_link_ksettings with
> this value.
>
> We also initialize advertising to zero, because otherwise it may
> be uninitialized if no case of the switch (tp->xcvr_select) is used.
>
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
[...]

MBR, Sergei
