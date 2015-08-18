From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rt2x00: adjust EEPROM_SIZE for rt2500usb
Date: Tue, 18 Aug 2015 06:05:23 +0000 (UTC)
Message-ID: <20150818060523.707B1140394@smtp.codeaurora.org>
References: <1439245553-2840-1-git-send-email-adrien+dev@schischi.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, helmut.schaa@googlemail.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Adrien Schildknecht <adrien+dev@schischi.me>
To: Adrien Schildknecht <adrien+dev@schischi.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439245553-2840-1-git-send-email-adrien+dev@schischi.me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> rt2500usb_validate_eeprom() read data up to 0x6e (EEPROM_CALIBRATE_OFFSET)
> but only 0x6a bytes has been allocated and read from the eeprom.
> 
> This lead to out-of-bound accesses and invalid values for
> EEPROM_BBPTUNE_R17 and EEPROM_CALIBRATE_OFFSET.
> 
> Change the EEPROM_SIZE to 0x6e in order to retrieve all the fields.
> 
> Tested with a rt2570 device.
> 
> Signed-off-by: Adrien Schildknecht <adrien+dev@schischi.me>
> Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
