From: Grant Grundler <iod00d@hp.com>
Subject: Re: OK if tg3_get_eeprom_hw_cfg() reads SRAM?
Date: Thu, 18 Aug 2005 10:03:05 -0700
Message-ID: <20050818170305.GA15077@esmail.cup.hp.com>
References: <B1508D50A0692F42B217C22C02D84972067F090E@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <B1508D50A0692F42B217C22C02D84972067F090E@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 18, 2005 at 12:40:42AM -0700, Michael Chan wrote:
> > Is it OK for tg3_get_eeprom_hw_cfg() to read
> > NIC_SRAM_DATA_CFG?
> 
> Yes, NIC_SRAM_DATA_CFG is in memory space (as opposed to
> register space) and we always use config. cycles to
> read/write memory space. Please see tg3_read/write_mem().

doh! of course...I've looked at tg3_read_mem() more than
a few times.

thanks,
grant
