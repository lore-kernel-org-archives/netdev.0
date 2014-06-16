From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: netconsole breaks netpoll on bridge
Date: Mon, 16 Jun 2014 23:30:19 +0200
Message-ID: <20140616213019.GA31594@electric-eye.fr.zoreil.com>
References: <539EE86E.6030806@profihost.ag>
 <CAHA+R7OrT+x_jvDeqKgFc=ndebhB6qwecJBcT5y0ZAA+hBCJ3Q@mail.gmail.com>
 <6B8712E6-8012-42C3-9D98-0EBD943F2894@profihost.ag>
 <CAHA+R7NUKXJhaX45+OQx3ufxrWjkjnhO84cNznbijOZWru7u6w@mail.gmail.com>
 <CE582178-E749-473F-9D88-E6D7789A3B73@profihost.ag>
 <CAHA+R7Ncr_96hcTCgnxWnjXpKvW09DWMZ7J_W4n3GK0VtEo9VA@mail.gmail.com>
 <835D3F57-EB3A-4D30-B19C-7CC987D06C55@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <cwang@twopensource.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <835D3F57-EB3A-4D30-B19C-7CC987D06C55@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stefan Priebe - Profihost AG <s.priebe@profihost.ag> :
[...]
> That sounds great! Is there anything I can do or some code I can port to veth?

You may add an empty handler for .ndo_poll_controller in drivers/net/veth.c
and give it a try on current kernel.

It should not be too bad.

-- 
Ueimor
