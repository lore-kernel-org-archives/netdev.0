From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] rt2x00: adjust EEPROM_SIZE for rt2500usb
Date: Wed, 12 Aug 2015 11:00:24 +0200
Message-ID: <20150812090023.GA1862@redhat.com>
References: <1439245553-2840-1-git-send-email-adrien+dev@schischi.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: helmut.schaa@googlemail.com, kvalo@codeaurora.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrien Schildknecht <adrien+dev@schischi.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1439245553-2840-1-git-send-email-adrien+dev@schischi.me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 11, 2015 at 12:25:53AM +0200, Adrien Schildknecht wrote:
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

Acked-by: Stanislaw Gruszka <sgruszka@redhat.com>
