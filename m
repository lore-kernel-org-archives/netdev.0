From: "Rami Rosen" <rosenrami@gmail.com>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sun, 4 Jun 2006 21:03:01 +0300
Message-ID: <ae5426fb0606041103od6bf095sd4403ab2966a1e1f@mail.gmail.com>
References: <44817083.508@gentoo.org> <200606040025.32275.oliver@neukum.org>
	 <ada605fb0606040929p7a6ea69aw9488a75d611b23e5@mail.gmail.com>
	 <200606041917.55496.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John Que" <qwejohn@gmail.com>, "Daniel Drake" <dsd@gentoo.org>,
	linux-usb-devel@lists.sourceforge.net,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, "Ulrich Kunitz" <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:18517 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1750839AbWFDSDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Jun 2006 14:03:03 -0400
Received: by ug-out-1314.google.com with SMTP id a2so1042498ugf
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2006 11:03:01 -0700 (PDT)
To: "Oliver Neukum" <oliver@neukum.org>
In-Reply-To: <200606041917.55496.oliver@neukum.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

   While I did not yet review fully the code , I saw some definitions
which are not in use. (more than 150 such definitions, in one file)  I
think it may be better to remove this #define statements to make the
code more readable. In case there will be a need in the future, the needed
#define statements can be returned.
The definitions which are not in use are from zd_chip.h.

It is mentioned there that these definitions are taken from the ZYDAS
driver and  not all of them are relevant for the rewrite driver;
however, it seems to me that
removing them may be thought of.


Anyhow you did a great job and I hope I will find time to really delve
into the code.

The definitions I am talking about are: (see zd_chip.h)

CR_RF_IF_CLK
CR_RF_IF_DATA
CR_PE1_PE2
CR_PE2_DLY
CR_LE1
CR_LE2
CR_RADIO_PD
CR_RF2948_PD
CR_ENABLE_PS_MANUAL_AGC
CR_SA2400_SER_AP
CR_I2C_WRITE
CR_SA2400_SER_RP
CR_RADIO_PE
CR_RST_BUS_MASTER
CR_HSTSCHG
CR_PHY_ON
CR_RX_DELAY
CR_GPIO_1
CR_GPIO_2
CR_EncryBufMux
CR_MAC_PS_STATE
INT_TX_COMPLETE			
INT_RX_COMPLETE
INT_RETRY_FAIL
INT_WAKEUP
INT_DTIM_NOTIFY
INT_CFG_NEXT_BCN
INT_BUS_ABORT
INT_TX_FIFO_READY
INT_UART
INT_TX_COMPLETE_EN		
INT_RX_COMPLETE_EN
INT_RETRY_FAIL_EN
INT_WAKEUP_EN
INT_DTIM_NOTIFY_EN
INT_CFG_NEXT_BCN_EN
INT_BUS_ABORT_EN
INT_TX_FIFO_READY_EN
INT_UART_EN
CR_TSF_LOW_PART
CR_TSF_HIGH_PART
CR_UART_RBR_THR_DLL
CR_UART_DLM_IER
CR_UART_IIR_FCR
CR_UART_LCR
CR_UART_MCR
CR_UART_LSR			
CR_UART_MSR			
CR_UART_ECR			
CR_UART_STATUS			
CR_PCI_TX_ADDR_P1		
CR_PCI_TX_AddR_P2		
CR_PCI_RX_AddR_P1		
CR_PCI_RX_AddR_P2		
CR_BSSID_P1			
CR_BSSID_P2			
CR_RX_TIMEOUT
CR_RATE_9M
CR_RATE_18M
CR_RATE_36M
CR_RATE_48M
CR_RATE_54M
CR_RX_OFFSET
CR_PHY_DELAY
CR_BCN_FIFO
CR_DEVICE_STATE
CR_UNDERRUN_CNT
CR_BCN_FIFO_SEMAPHORE
CR_IFS_VALUE
CR_RX_TIME_OUT
CR_TOTAL_RX_FRM
CR_CRC32_CNT
CR_CRC16_CNT
CR_DECRYPTION_ERR_UNI
CR_RX_FIFO_OVERRUN
CR_DECRYPTION_ERR_MUL
CR_NAV_CNT
CR_NAV_CCA
CR_RETRY_CNT
CR_READ_TCB_ADDR
CR_READ_RFD_ADDR
CR_TOTAL_TX_FRM
CR_CAM_MODE
CR_CAM_ROLL_TB_LOW
CR_CAM_ROLL_TB_HIGH
CR_CAM_ADDRESS
CR_CAM_DATA
CR_ROMDIR
CR_DECRY_ERR_FLG_LOW
CR_DECRY_ERR_FLG_HIGH
CR_WEPKEY0
CR_WEPKEY1
CR_WEPKEY2
CR_WEPKEY3
CR_WEPKEY4
CR_WEPKEY5
CR_WEPKEY6
CR_WEPKEY7
CR_WEPKEY8
CR_WEPKEY9
CR_WEPKEY10
CR_WEPKEY11
CR_WEPKEY12
CR_WEPKEY13
CR_WEPKEY14
CR_WEPKEY15
CR_TKIP_MODE
CR_EEPROM_PROTECT0
CR_EEPROM_PROTECT1
CR_DBG_FIFO_RD
CR_DBG_SELECT
CR_FIFO_Length
CR_RSSI_MGC
CR_PON
CR_RX_ON
CR_TX_ON
CR_CHIP_EN
CR_LO_SW
CR_TXRX_SW
CR_S_MD
CR_USB_DEBUG_PORT
STA_RX_FILTER
E2P_PWR_CAL_VALUE2
E2P_PWR_CAL_VALUE3
E2P_PWR_CAL_VALUE4
E2P_PWR_INT_VALUE2
E2P_PWR_INT_VALUE3
E2P_PWR_INT_VALUE4
E2P_ALLOWED_CHANNEL
E2P_DEVICE_VER
E2P_36M_CAL_VALUE2
E2P_36M_CAL_VALUE3
E2P_36M_CAL_VALUE4
E2P_11A_INT_VALUE1
E2P_11A_INT_VALUE2
E2P_11A_INT_VALUE3
E2P_11A_INT_VALUE4
E2P_48M_CAL_VALUE2
E2P_48M_CAL_VALUE3
E2P_48M_CAL_VALUE4
E2P_48M_INT_VALUE1
E2P_48M_INT_VALUE2
E2P_48M_INT_VALUE3
E2P_48M_INT_VALUE4
E2P_54M_CAL_VALUE2
E2P_54M_CAL_VALUE3
E2P_54M_CAL_VALUE4
E2P_54M_INT_VALUE1
E2P_54M_INT_VALUE2
E2P_54M_INT_VALUE3
E2P_54M_INT_VALUE4
FW_SOFT_RESET
FW_FLASH_CHK

Regards,
Rami Rosen



On 6/4/06, Oliver Neukum <oliver@neukum.org> wrote:
> Am Sonntag, 4. Juni 2006 18:29 schrieb John Que:
> > I had noticed that the zd1211 driver does call request_irq() in zd1205_open(),
> > file zd1205.c; grepping for request_irq() in the rewrite driver yields
> > no results.
> > (I looked at the rewrite version from a week ago but in this point it
> > is probably the
> > same).
> > Why is this so ? I assume that the softmac layer does not call request_irq() on
> > behalf of the driver because this is not supposed to be like it, as I understand
> > its functionality. Can anybody briefly calrify this point ?
>
> A USB driver never will request an irq. Interrupt handling is done in
> the core usb layer. Individual drivers have no business there.
>
>         Regards
>                 Oliver
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
