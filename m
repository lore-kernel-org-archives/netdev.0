From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [PATCH 02/10] lantiq_etop: set addr_assign_type if random_ether_addr() used
Date: Fri, 17 Feb 2012 22:24:35 +0100
Message-ID: <201202172224.35902.danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de> <1329493411-25750-3-git-send-email-danny.kukawka@bisect.de> <20120217.160006.1000847808550095794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: blogic@openwrt.org, ralf@linux-mips.org,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120217.160006.1000847808550095794.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Freitag, 17. Februar 2012, David Miller wrote:
> From: Danny Kukawka <danny.kukawka@bisect.de>
> Date: Fri, 17 Feb 2012 16:43:23 +0100
>
> > Set addr_assign_type correctly to NET_ADDR_RANDOM in case
> > a random MAC address was generated and assigned to the netdevice.
> >
> > v2: added comment, renamed bool variable to random_mac
> >
> > Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
>
> More bad comment formatting.
>
> > +	/*set addr_assign_type here, ltq_etop_set_mac_address would reset it*/
>
> Again, I fixed it up but I will not next time.

Thanks. I fixed it but accidently send the unfixed version of the patches 
without noticing. Sorry.

Danny
