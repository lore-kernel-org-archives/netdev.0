From: David Miller <davem@davemloft.net>
Subject: Re: RESEND: [PATCH v3 net-next] sky2: use random address if EEPROM
 is bad
Date: Tue, 29 Sep 2015 15:00:22 -0700 (PDT)
Message-ID: <20150929.150022.2172906859127167304.davem@davemloft.net>
References: <1443459111-15595-1-git-send-email-Liviu.Dudau@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, mlindner@marvell.com,
	f.fainelli@gmail.com, ryan.harkin@linaro.org,
	sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Liviu.Dudau@arm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443459111-15595-1-git-send-email-Liviu.Dudau@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liviu Dudau <Liviu.Dudau@arm.com>
Date: Mon, 28 Sep 2015 17:51:51 +0100

> On some embedded systems the EEPROM does not contain a valid MAC address.
> In that case it is better to fallback to a generated mac address and
> let init scripts fix the value later.
> 
> Reported-by: Liviu Dudau <Liviu.Dudau@arm.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> [Changed handcoded setup to use eth_hw_addr_random() and to save new address into HW]
> Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>

Applied, thanks.
