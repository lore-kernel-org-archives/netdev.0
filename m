From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] brcmfmac: prevent watchdog from interfering with
	scanning and connecting
Date: Mon, 4 Aug 2014 17:47:58 +0100
Message-ID: <20140804164758.GF30282@n2100.arm.linux.org.uk>
References: <539E8559.3010601@linux.intel.com> <539EA79C.7010206@broadcom.com> <53A30F96.3010206@linux.intel.com> <53A311E4.301@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Fu, Zhonghui" <zhonghui.fu@linux.intel.com>, brudley@broadcom.com,
	Franky Lin <frankyl@broadcom.com>, meuleman@broadcom.com,
	linville@tuxdriver.com, pieterpg@broadcom.com, dekim@broadcom.com,
	mcgrof@do-not-panic.com, antonio@open-mesh.com,
	johannes.berg@intel.com, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53A311E4.301@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 19, 2014 at 06:37:56PM +0200, Arend van Spriel wrote:
> On 19-06-14 18:28, Fu, Zhonghui wrote:
>> I have tried brcmfmac driver with "CONFIG_PM_RUNTIME is not set", and scanning and connecting  always succeeded. This means that CONFIG_PM_RUNTIME should not be set if we use SDIO WiFi device driven by brcmfmac driver, right?
>
> Depends which kernel you are using. In 3.16-rc1 the sdio interrupt issue  
> has been fixed so you should be fine to use CONFIG_PM_RUNTIME. Here is  
> the commit

I have to say that scanning with the 4329 device seems utterly useless,
whereas 4330 works fine.  Apart from the broadcom chip, the rest of the
hardware is identical.

-- 
FTTC broadband for 0.8mile line: currently at 9.5Mbps down 400kbps up
according to speedtest.net.
