From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 4/8] trivial: fix some typos and punctuation in comments
Date: Thu, 15 Oct 2009 22:07:40 +0200
Message-ID: <200910152207.41996.IvDoorn@gmail.com>
References: <1255636103-5817-1-git-send-email-cascardo@holoscopio.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, linville@tuxdriver.com,
	johannes@sipsolutions.net, users@rt2x00.serialmonkey.com,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:60789 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbZJOUIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 16:08:23 -0400
In-Reply-To: <1255636103-5817-1-git-send-email-cascardo@holoscopio.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 October 2009, Thadeu Lima de Souza Cascardo wrote:
> Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>

Acked-by: Ivo van Doorn <IvDoorn@gmail.com>

> ---
>  drivers/net/wireless/rt2x00/rt61pci.c |   36 ++++++++++++++++----------------
>  1 files changed, 18 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
> index b20e3ea..343e565 100644
> --- a/drivers/net/wireless/rt2x00/rt61pci.c
> +++ b/drivers/net/wireless/rt2x00/rt61pci.c
> @@ -51,7 +51,7 @@ MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
>   * These indirect registers work with busy bits,
>   * and we will try maximal REGISTER_BUSY_COUNT times to access
>   * the register while taking a REGISTER_BUSY_DELAY us delay
> - * between each attampt. When the busy bit is still set at that time,
> + * between each attempt. When the busy bit is still set at that time,
>   * the access attempt is considered to have failed,
>   * and we will print an error.
>   */
> @@ -386,7 +386,7 @@ static int rt61pci_config_shared_key(struct rt2x00_dev *rt2x00dev,
>  		 * The driver does not support the IV/EIV generation
>  		 * in hardware. However it doesn't support the IV/EIV
>  		 * inside the ieee80211 frame either, but requires it
> -		 * to be provided seperately for the descriptor.
> +		 * to be provided separately for the descriptor.
>  		 * rt2x00lib will cut the IV/EIV data out of all frames
>  		 * given to us by mac80211, but we must tell mac80211
>  		 * to generate the IV/EIV data.
> @@ -397,7 +397,7 @@ static int rt61pci_config_shared_key(struct rt2x00_dev *rt2x00dev,
>  	/*
>  	 * SEC_CSR0 contains only single-bit fields to indicate
>  	 * a particular key is valid. Because using the FIELD32()
> -	 * defines directly will cause a lot of overhead we use
> +	 * defines directly will cause a lot of overhead, we use
>  	 * a calculation to determine the correct bit directly.
>  	 */
>  	mask = 1 << key->hw_key_idx;
> @@ -425,11 +425,11 @@ static int rt61pci_config_pairwise_key(struct rt2x00_dev *rt2x00dev,
>  		/*
>  		 * rt2x00lib can't determine the correct free
>  		 * key_idx for pairwise keys. We have 2 registers
> -		 * with key valid bits. The goal is simple, read
> -		 * the first register, if that is full move to
> +		 * with key valid bits. The goal is simple: read
> +		 * the first register. If that is full, move to
>  		 * the next register.
> -		 * When both registers are full, we drop the key,
> -		 * otherwise we use the first invalid entry.
> +		 * When both registers are full, we drop the key.
> +		 * Otherwise, we use the first invalid entry.
>  		 */
>  		rt2x00pci_register_read(rt2x00dev, SEC_CSR2, &reg);
>  		if (reg && reg == ~0) {
> @@ -464,8 +464,8 @@ static int rt61pci_config_pairwise_key(struct rt2x00_dev *rt2x00dev,
>  					      &addr_entry, sizeof(addr_entry));
>  
>  		/*
> -		 * Enable pairwise lookup table for given BSS idx,
> -		 * without this received frames will not be decrypted
> +		 * Enable pairwise lookup table for given BSS idx.
> +		 * Without this, received frames will not be decrypted
>  		 * by the hardware.
>  		 */
>  		rt2x00pci_register_read(rt2x00dev, SEC_CSR4, &reg);
> @@ -487,7 +487,7 @@ static int rt61pci_config_pairwise_key(struct rt2x00_dev *rt2x00dev,
>  	/*
>  	 * SEC_CSR2 and SEC_CSR3 contain only single-bit fields to indicate
>  	 * a particular key is valid. Because using the FIELD32()
> -	 * defines directly will cause a lot of overhead we use
> +	 * defines directly will cause a lot of overhead, we use
>  	 * a calculation to determine the correct bit directly.
>  	 */
>  	if (key->hw_key_idx < 32) {
> @@ -556,7 +556,7 @@ static void rt61pci_config_intf(struct rt2x00_dev *rt2x00dev,
>  	if (flags & CONFIG_UPDATE_TYPE) {
>  		/*
>  		 * Clear current synchronisation setup.
> -		 * For the Beacon base registers we only need to clear
> +		 * For the Beacon base registers, we only need to clear
>  		 * the first byte since that byte contains the VALID and OWNER
>  		 * bits which (when set to 0) will invalidate the entire beacon.
>  		 */
> @@ -1168,8 +1168,8 @@ static int rt61pci_check_firmware(struct rt2x00_dev *rt2x00dev,
>  		return FW_BAD_LENGTH;
>  
>  	/*
> -	 * The last 2 bytes in the firmware array are the crc checksum itself,
> -	 * this means that we should never pass those 2 bytes to the crc
> +	 * The last 2 bytes in the firmware array are the crc checksum itself.
> +	 * This means that we should never pass those 2 bytes to the crc
>  	 * algorithm.
>  	 */
>  	fw_crc = (data[len - 2] << 8 | data[len - 1]);
> @@ -1986,7 +1986,7 @@ static void rt61pci_fill_rxdone(struct queue_entry *entry,
>  
>  		/*
>  		 * Hardware has stripped IV/EIV data from 802.11 frame during
> -		 * decryption. It has provided the data seperately but rt2x00lib
> +		 * decryption. It has provided the data separately but rt2x00lib
>  		 * should decide if it should be reinserted.
>  		 */
>  		rxdesc->flags |= RX_FLAG_IV_STRIPPED;
> @@ -2042,7 +2042,7 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2x00dev)
>  	 * During each loop we will compare the freshly read
>  	 * STA_CSR4 register value with the value read from
>  	 * the previous loop. If the 2 values are equal then
> -	 * we should stop processing because the chance it
> +	 * we should stop processing because the chance is
>  	 * quite big that the device has been unplugged and
>  	 * we risk going into an endless loop.
>  	 */
> @@ -2330,7 +2330,7 @@ static int rt61pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
>  		__set_bit(CONFIG_FRAME_TYPE, &rt2x00dev->flags);
>  
>  	/*
> -	 * Detect if this device has an hardware controlled radio.
> +	 * Detect if this device has a hardware controlled radio.
>  	 */
>  	if (rt2x00_get_field16(eeprom, EEPROM_ANTENNA_HARDWARE_RADIO))
>  		__set_bit(CONFIG_SUPPORT_HW_BUTTON, &rt2x00dev->flags);
> @@ -2355,7 +2355,7 @@ static int rt61pci_init_eeprom(struct rt2x00_dev *rt2x00dev)
>  		__set_bit(CONFIG_EXTERNAL_LNA_BG, &rt2x00dev->flags);
>  
>  	/*
> -	 * When working with a RF2529 chip without double antenna
> +	 * When working with a RF2529 chip without double antenna,
>  	 * the antenna settings should be gathered from the NIC
>  	 * eeprom word.
>  	 */
> @@ -2668,7 +2668,7 @@ static int rt61pci_conf_tx(struct ieee80211_hw *hw, u16 queue_idx,
>  
>  	/*
>  	 * We only need to perform additional register initialization
> -	 * for WMM queues/
> +	 * for WMM queues.
>  	 */
>  	if (queue_idx >= 4)
>  		return 0;


