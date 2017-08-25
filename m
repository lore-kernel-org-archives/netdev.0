From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] e1000e: Be drop monitor friendly
Date: Thu, 24 Aug 2017 20:06:42 -0700
Message-ID: <6475bbf2-9035-5630-e03e-66c2fdf1af0d@gmail.com>
References: <20170825013650.27463-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: edumazet@gmail.com, davem@davemloft.net,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "moderated list:INTEL ETHERNET DRIVERS"
        <intel-wired-lan@lists.osuosl.org>,
        open list <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170825013650.27463-1-f.fainelli@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 08/24/2017 06:36 PM, Florian Fainelli wrote:
> e1000_put_txbuf() cleans up the successfully transmitted TX packets,
> e1000e_tx_hwtstamp_work() also does the successfully completes the
> timestamped TX packets, e1000_clean_rx_ring() cleans up the RX ring and
> e1000_remove() cleans up the timestampted packets. None of these
> functions should be reporting dropped packets, so make them use
> dev_consume_skb*() to be drop monitor friendly.

This also won't compile, I marked it a Superseded in patchwork since
there is a v2 coming.

-- 
Florian
