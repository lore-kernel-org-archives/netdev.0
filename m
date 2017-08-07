From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next 0/5] Refactor lan9303_xxx_packet_processing
Date: Mon, 07 Aug 2017 14:18:38 -0700 (PDT)
Message-ID: <20170807.141838.1486515755418560591.davem@davemloft.net>
References: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel@pengutronix.de
To: privat@egil-hjelmeland.no
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170805110550.26337-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Date: Sat,  5 Aug 2017 13:05:45 +0200

> This series is purely non functional. 
> 
> It changes the lan9303_enable_packet_processing,
> lan9303_disable_packet_processing() to pass port number (0,1,2) as
> parameter instead of port offset. This aligns them with
> other functions in the module, and makes it possible to simplify the code.
> 
> The lan9303_enable_packet_processing, lan9303_disable_packet_processing
> functions operate on port. Therefore rename the functions to reflect that
> as well.
> 
> Reviewer pointed out lan9303_get_ethtool_stats would be better off with
> the use of a lan9303_read_switch_port(). So that was added to the series.
 ...

Series applied, thank you.
