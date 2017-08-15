From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 05/11] net: dsa: debugfs: add port stats
Date: Tue, 15 Aug 2017 10:34:02 -0700
Message-ID: <8badb63e-6d7e-2a91-cb44-0c732d4fa744@gmail.com>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170814222242.10643-6-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/14/2017 03:22 PM, Vivien Didelot wrote:
> Add a debug filesystem "stats" entry to query a port's hardware
> statistics through the DSA switch .get_sset_count, .get_strings and
> .get_ethtool_stats operations.
> 
> This allows one to get statistics about DSA links interconnecting
> switches, which is very convenient because this kind of port is not
> exposed to userspace.
> 
> Here are the stats of a zii-rev-b DSA and CPU ports:
> 
>     # pr -mt switch0/port{5,6}/stats
>     in_good_octets      : 0             in_good_octets      : 13824
>     in_bad_octets       : 0             in_bad_octets       : 0
>     in_unicast          : 0             in_unicast          : 0
>     in_broadcasts       : 0             in_broadcasts       : 216
>     in_multicasts       : 0             in_multicasts       : 0
>     in_pause            : 0             in_pause            : 0
>     in_undersize        : 0             in_undersize        : 0
>     in_fragments        : 0             in_fragments        : 0
>     in_oversize         : 0             in_oversize         : 0
>     in_jabber           : 0             in_jabber           : 0
>     in_rx_error         : 0             in_rx_error         : 0
>     in_fcs_error        : 0             in_fcs_error        : 0
>     out_octets          : 9216          out_octets          : 0
>     out_unicast         : 0             out_unicast         : 0
>     out_broadcasts      : 144           out_broadcasts      : 0
>     out_multicasts      : 0             out_multicasts      : 0
>     out_pause           : 0             out_pause           : 0
>     excessive           : 0             excessive           : 0
>     collisions          : 0             collisions          : 0
>     deferred            : 0             deferred            : 0
>     single              : 0             single              : 0
>     multiple            : 0             multiple            : 0
>     out_fcs_error       : 0             out_fcs_error       : 0
>     late                : 0             late                : 0
>     hist_64bytes        : 0             hist_64bytes        : 0
>     hist_65_127bytes    : 0             hist_65_127bytes    : 0
>     hist_128_255bytes   : 0             hist_128_255bytes   : 0
>     hist_256_511bytes   : 0             hist_256_511bytes   : 0
>     hist_512_1023bytes  : 0             hist_512_1023bytes  : 0
>     hist_1024_max_bytes : 0             hist_1024_max_bytes : 0
>     sw_in_discards      : 0             sw_in_discards      : 0
>     sw_in_filtered      : 0             sw_in_filtered      : 0
>     sw_out_filtered     : 0             sw_out_filtered     : 216
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
