From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-drivers-2.6 2/10] e1000: use netif_poll_{enable|disable}
Date: Wed, 16 Feb 2005 00:30:20 +0100
Message-ID: <20050215233020.GB1755@electric-eye.fr.zoreil.com>
References: <468F3FDA28AA87429AD807992E22D07E04438B87@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>,
        jgarzik@pobox.com, netdev@oss.sgi.com
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E04438B87@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Venkatesan, Ganesh <ganesh.venkatesan@intel.com> :
> I agree that this causes our ISR to be called where no useful work will
> be done -- netif_rx_schedule_prep() will fail till netif_poll_enable is
> called.
> However, there should not be any adverse side effects due to this.

Right, the irq does not need an extra ack. Sorry for the noise.

--
Ueimor
