From: Peter Stuge <peter@stuge.se>
Subject: Re: [PATCH 2/2] ath: Fix logging message typos
Date: Thu, 2 Dec 2010 06:30:54 +0100
Message-ID: <20101202053055.19479.qmail@stuge.se>
References: <276469c602c402565b49f99521ea19757429e81e.1291266731.git.joe@perches.com>
	<a345e995a816576a4c2c39aec43716c18011475b.1291266731.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>,
	netdev@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	Bob Copeland <me@bobcopeland.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	ath9k-devel@lists.ath9k.org, Nick Kossifidis <mickflemm@gmail.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
Content-Disposition: inline
In-Reply-To: <a345e995a816576a4c2c39aec43716c18011475b.1291266731.git.joe@perches.com>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

Joe Perches wrote:
> +++ b/drivers/net/wireless/ath/ath9k/ar9002_calib.c
..
> @@ -734,7 +734,7 @@ static bool ar9285_hw_cl_cal(struct ath_hw *ah, struct ath9k_channel *chan)
>  	if (!ath9k_hw_wait(ah, AR_PHY_AGC_CONTROL, AR_PHY_AGC_CONTROL_CAL,
>  			  0, AH_WAIT_TIMEOUT)) {
>  		ath_dbg(common, ATH_DBG_CALIBRATE,
> -			"offset calibration failed to complete in 1ms; noisy ??\n");
> +			"offset calibration failed to complete in 1ms; noisy enfironment?\n");

enfironment? :)


> +++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
..
> @@ -1178,7 +1178,7 @@ static u16 ath9k_hw_4k_get_spur_channel(struct ath_hw *ah, u16 i, bool is2GHz)
>  	u16 spur_val = AR_NO_SPUR;
>  
>  	ath_dbg(common, ATH_DBG_ANI,
> -		"Getting spur idx %d is2Ghz. %d val %x\n",
> +		"Getting spur idx:%d is2Ghz:%d val:%x\n",
>  		i, is2GHz, ah->config.spurchans[i][is2GHz]);

Is this short for "spurious" ?


//Peter
