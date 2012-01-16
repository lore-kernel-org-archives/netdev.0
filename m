From: Tomoya MORINAGA <tomoya.rohm@gmail.com>
Subject: Re: [PATCH] pch_gbe: Use a randomly generated MAC instead of failing probe
Date: Mon, 16 Jan 2012 16:38:23 +0900
Message-ID: <CANKRQnge1n4M7W5xCqwyGzXp8J3eK1HbZVRqGW7BoE5iOwYCDQ@mail.gmail.com>
References: <132d2a41a089905de3147b4656e350608aa7fd6f.1326523495.git.dvhart@linux.intel.com>
	<20120114.001430.787918662083526597.davem@davemloft.net>
	<4F11A533.4040406@linux.intel.com>
	<20120114.115604.2101782124431552110.davem@davemloft.net>
	<20120114214658.4ddfec30@pyramind.ukuu.org.uk>
	<4F120357.3020808@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, arjan@linux.intel.com,
	alan@linux.intel.com, jeffrey.t.kirsher@intel.com,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	netdev@vger.kernel.org
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F120357.3020808@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/1/16 Darren Hart <darren.hart@intel.com>:
> I have since resolved this particular issue. I did not disable the
> pcieqos driver I forward ported. With that disabled, pch_phub works as
> expected.
Yes, you can not use both pcieqos and pch_phub at the same time.
Because pcieqos is previous version of pch_phub which is upstreamed.


> Which is to say it lists pch_mac, reads all 0's, and does
> nothing on write (since the MAC ROM doesn't exist). Please see the patch
> thread from Friday to address this using a random mac if the ROM is
> missing or invalid.
Saving MAC address into external ROM is generic method, I think.
Though I know the ROM-less system using eg20t-pch, however I think
this system is not common.
So, I think pch_gbe shouldn't have auto-mac address assignment.

BTW, as you know, a use can write MAC address using sysfs file system
like below.
echo aa:bb:cc:dd:ee:ff > pch_mac

thanks,
tomoya
