From: Grant Grundler <iod00d@hp.com>
Subject: OK if tg3_get_eeprom_hw_cfg() reads SRAM?
Date: Wed, 17 Aug 2005 23:34:52 -0700
Message-ID: <20050818063452.GA13262@esmail.cup.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Grant Grundler <iod00d@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, mchan@broadcom.hp.com.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael,
tg3_get_eeprom_hw_cfg() was added in this patch:
	http://www.kernel.org/git/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=7d0c41ef89dad9008edf1c3c0022721ebad39999

The comment before tg3_get_eeprom_hw_cfg() suggests tg3 should
ONLY be touching PCI cfg space until the NIC gets to D0 power state.
But tg3_get_eeprom_hw_cfg() is called before tg3_set_power_state(tp,0).

Is it OK for tg3_get_eeprom_hw_cfg() to read NIC_SRAM_DATA_CFG?

thanks,
grant
