From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [net-next:master 182/190] drivers/net/ethernet/adi/bfin_mac.c:694:2:
 error: implicit declaration of function 'bfin_read_EMAC_PTP_CTL'
Date: Sun, 4 Nov 2012 08:55:55 +0800
Message-ID: <20121104005555.GC7304@localhost>
References: <509593bb.gIzsCzaNw8m7sNor%yuanhan.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36598 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864Ab2KDA4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2012 20:56:00 -0400
Content-Disposition: inline
In-Reply-To: <509593bb.gIzsCzaNw8m7sNor%yuanhan.liu@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Richard,

FYI, kernel build failed on

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   f7c3f96a41f16865e6422bfb919312a716b16552
commit: 70ac618c07b6ef959ff79a276b8d6c6626554dfd [182/190] ptp: fixup Kconfig for two PHC drivers.
config: make ARCH=blackfin BF526-EZBRD_defconfig

All error/warnings:

drivers/net/ethernet/adi/bfin_mac.c: In function 'bfin_mac_hwtstamp_ioctl':
drivers/net/ethernet/adi/bfin_mac.c:694:2: error: implicit declaration of function 'bfin_read_EMAC_PTP_CTL' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:702:3: error: implicit declaration of function 'bfin_write_EMAC_PTP_FV3' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:712:3: error: implicit declaration of function 'bfin_write_EMAC_PTP_CTL' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:717:3: error: implicit declaration of function 'bfin_write_EMAC_PTP_FOFF' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:723:3: error: implicit declaration of function 'bfin_write_EMAC_PTP_FV1' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:725:3: error: implicit declaration of function 'bfin_write_EMAC_PTP_FV2' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:804:14: error: 'PTP_EN' undeclared (first use in this function)
drivers/net/ethernet/adi/bfin_mac.c:804:14: note: each undeclared identifier is reported only once for each function it appears in
drivers/net/ethernet/adi/bfin_mac.c:815:3: error: implicit declaration of function 'bfin_read_EMAC_PTP_RXSNAPLO' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:816:3: error: implicit declaration of function 'bfin_read_EMAC_PTP_RXSNAPHI' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:818:3: error: implicit declaration of function 'bfin_read_EMAC_PTP_TXSNAPLO' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:819:3: error: implicit declaration of function 'bfin_read_EMAC_PTP_TXSNAPHI' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c: In function 'bfin_tx_hwtstamp':
drivers/net/ethernet/adi/bfin_mac.c:847:3: error: implicit declaration of function 'bfin_read_EMAC_PTP_ISTAT' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:847:42: error: 'TXTL' undeclared (first use in this function)
drivers/net/ethernet/adi/bfin_mac.c: In function 'bfin_rx_hwtstamp':
drivers/net/ethernet/adi/bfin_mac.c:876:39: error: 'RXEL' undeclared (first use in this function)
drivers/net/ethernet/adi/bfin_mac.c: In function 'bfin_mac_hwtstamp_init':
drivers/net/ethernet/adi/bfin_mac.c:900:2: error: implicit declaration of function 'bfin_write_EMAC_PTP_ADDEND' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c: In function 'bfin_ptp_time_read':
drivers/net/ethernet/adi/bfin_mac.c:917:2: error: implicit declaration of function 'bfin_read_EMAC_PTP_TIMELO' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:918:2: error: implicit declaration of function 'bfin_read_EMAC_PTP_TIMEHI' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c: In function 'bfin_ptp_time_write':
drivers/net/ethernet/adi/bfin_mac.c:935:2: error: implicit declaration of function 'bfin_write_EMAC_PTP_TIMELO' [-Werror=implicit-function-declaration]
drivers/net/ethernet/adi/bfin_mac.c:936:2: error: implicit declaration of function 'bfin_write_EMAC_PTP_TIMEHI' [-Werror=implicit-function-declaration]
cc1: some warnings being treated as errors

vim +694 +/bfin_read_EMAC_PTP_CTL drivers/net/ethernet/adi/bfin_mac.c

fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  688  		return -EINVAL;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  689  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  690  	if ((config.tx_type != HWTSTAMP_TX_OFF) &&
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  691  			(config.tx_type != HWTSTAMP_TX_ON))
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  692  		return -ERANGE;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  693  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @694  	ptpctl = bfin_read_EMAC_PTP_CTL();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  695  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  696  	switch (config.rx_filter) {
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  697  	case HWTSTAMP_FILTER_NONE:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  698  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  699  		 * Dont allow any timestamping
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  700  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  701  		ptpfv3 = 0xFFFFFFFF;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @702  		bfin_write_EMAC_PTP_FV3(ptpfv3);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  703  		break;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  704  	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  705  	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  706  	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  707  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  708  		 * Clear the five comparison mask bits (bits[12:8]) in EMAC_PTP_CTL)
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  709  		 * to enable all the field matches.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  710  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  711  		ptpctl &= ~0x1F00;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @712  		bfin_write_EMAC_PTP_CTL(ptpctl);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  713  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  714  		 * Keep the default values of the EMAC_PTP_FOFF register.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  715  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  716  		ptpfoff = 0x4A24170C;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @717  		bfin_write_EMAC_PTP_FOFF(ptpfoff);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  718  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  719  		 * Keep the default values of the EMAC_PTP_FV1 and EMAC_PTP_FV2
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  720  		 * registers.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  721  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  722  		ptpfv1 = 0x11040800;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @723  		bfin_write_EMAC_PTP_FV1(ptpfv1);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  724  		ptpfv2 = 0x0140013F;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @725  		bfin_write_EMAC_PTP_FV2(ptpfv2);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  726  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  727  		 * The default value (0xFFFC) allows the timestamping of both
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  728  		 * received Sync messages and Delay_Req messages.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  729  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  730  		ptpfv3 = 0xFFFFFFFC;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  731  		bfin_write_EMAC_PTP_FV3(ptpfv3);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  732  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  733  		config.rx_filter = HWTSTAMP_FILTER_PTP_V1_L4_EVENT;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  734  		break;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  735  	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  736  	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  737  	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  738  		/* Clear all five comparison mask bits (bits[12:8]) in the
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  739  		 * EMAC_PTP_CTL register to enable all the field matches.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  740  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  741  		ptpctl &= ~0x1F00;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  742  		bfin_write_EMAC_PTP_CTL(ptpctl);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  743  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  744  		 * Keep the default values of the EMAC_PTP_FOFF register, except set
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  745  		 * the PTPCOF field to 0x2A.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  746  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  747  		ptpfoff = 0x2A24170C;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  748  		bfin_write_EMAC_PTP_FOFF(ptpfoff);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  749  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  750  		 * Keep the default values of the EMAC_PTP_FV1 and EMAC_PTP_FV2
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  751  		 * registers.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  752  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  753  		ptpfv1 = 0x11040800;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  754  		bfin_write_EMAC_PTP_FV1(ptpfv1);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  755  		ptpfv2 = 0x0140013F;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  756  		bfin_write_EMAC_PTP_FV2(ptpfv2);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  757  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  758  		 * To allow the timestamping of Pdelay_Req and Pdelay_Resp, set
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  759  		 * the value to 0xFFF0.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  760  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  761  		ptpfv3 = 0xFFFFFFF0;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  762  		bfin_write_EMAC_PTP_FV3(ptpfv3);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  763  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  764  		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L4_EVENT;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  765  		break;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  766  	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  767  	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  768  	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  769  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  770  		 * Clear bits 8 and 12 of the EMAC_PTP_CTL register to enable only the
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  771  		 * EFTM and PTPCM field comparison.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  772  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  773  		ptpctl &= ~0x1100;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  774  		bfin_write_EMAC_PTP_CTL(ptpctl);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  775  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  776  		 * Keep the default values of all the fields of the EMAC_PTP_FOFF
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  777  		 * register, except set the PTPCOF field to 0x0E.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  778  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  779  		ptpfoff = 0x0E24170C;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  780  		bfin_write_EMAC_PTP_FOFF(ptpfoff);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  781  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  782  		 * Program bits [15:0] of the EMAC_PTP_FV1 register to 0x88F7, which
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  783  		 * corresponds to PTP messages on the MAC layer.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  784  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  785  		ptpfv1 = 0x110488F7;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  786  		bfin_write_EMAC_PTP_FV1(ptpfv1);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  787  		ptpfv2 = 0x0140013F;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  788  		bfin_write_EMAC_PTP_FV2(ptpfv2);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  789  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  790  		 * To allow the timestamping of Pdelay_Req and Pdelay_Resp
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  791  		 * messages, set the value to 0xFFF0.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  792  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  793  		ptpfv3 = 0xFFFFFFF0;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  794  		bfin_write_EMAC_PTP_FV3(ptpfv3);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  795  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  796  		config.rx_filter = HWTSTAMP_FILTER_PTP_V2_L2_EVENT;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  797  		break;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  798  	default:
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  799  		return -ERANGE;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  800  	}
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  801  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  802  	if (config.tx_type == HWTSTAMP_TX_OFF &&
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  803  	    bfin_mac_hwtstamp_is_none(config.rx_filter)) {
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @804  		ptpctl &= ~PTP_EN;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  805  		bfin_write_EMAC_PTP_CTL(ptpctl);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  806  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  807  		SSYNC();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  808  	} else {
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  809  		ptpctl |= PTP_EN;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  810  		bfin_write_EMAC_PTP_CTL(ptpctl);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  811  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  812  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  813  		 * clear any existing timestamp
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  814  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @815  		bfin_read_EMAC_PTP_RXSNAPLO();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @816  		bfin_read_EMAC_PTP_RXSNAPHI();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  817  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @818  		bfin_read_EMAC_PTP_TXSNAPLO();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @819  		bfin_read_EMAC_PTP_TXSNAPHI();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  820  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  821  		SSYNC();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  822  	}
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  823  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  824  	lp->stamp_cfg = config;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  825  	return copy_to_user(ifr->ifr_data, &config, sizeof(config)) ?
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  826  		-EFAULT : 0;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  827  }
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  828  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  829  static void bfin_tx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  830  {
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  831  	struct bfin_mac_local *lp = netdev_priv(netdev);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  832  
2244d07b drivers/net/bfin_mac.c              Oliver Hartkopp 2010-08-17  833  	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) {
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  834  		int timeout_cnt = MAX_TIMEOUT_CNT;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  835  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  836  		/* When doing time stamping, keep the connection to the socket
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  837  		 * a while longer
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  838  		 */
2244d07b drivers/net/bfin_mac.c              Oliver Hartkopp 2010-08-17  839  		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  840  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  841  		/*
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  842  		 * The timestamping is done at the EMAC module's MII/RMII interface
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  843  		 * when the module sees the Start of Frame of an event message packet. This
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  844  		 * interface is the closest possible place to the physical Ethernet transmission
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  845  		 * medium, providing the best timing accuracy.
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  846  		 */
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @847  		while ((!(bfin_read_EMAC_PTP_ISTAT() & TXTL)) && (--timeout_cnt))
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  848  			udelay(1);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  849  		if (timeout_cnt == 0)
c6dd5098 drivers/net/bfin_mac.c              Mike Frysinger  2011-01-10  850  			netdev_err(netdev, "timestamp the TX packet failed\n");
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  851  		else {
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  852  			struct skb_shared_hwtstamps shhwtstamps;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  853  			u64 ns;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  854  			u64 regval;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  855  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  856  			regval = bfin_read_EMAC_PTP_TXSNAPLO();
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  857  			regval |= (u64)bfin_read_EMAC_PTP_TXSNAPHI() << 32;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  858  			memset(&shhwtstamps, 0, sizeof(shhwtstamps));
bc3c5f63 drivers/net/ethernet/adi/bfin_mac.c Richard Cochran 2012-10-31  859  			ns = regval << lp->shift;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  860  			shhwtstamps.hwtstamp = ns_to_ktime(ns);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  861  			skb_tstamp_tx(skb, &shhwtstamps);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  862  		}
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  863  	}
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  864  }
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  865  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  866  static void bfin_rx_hwtstamp(struct net_device *netdev, struct sk_buff *skb)
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  867  {
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  868  	struct bfin_mac_local *lp = netdev_priv(netdev);
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  869  	u32 valid;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  870  	u64 regval, ns;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  871  	struct skb_shared_hwtstamps *shhwtstamps;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  872  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  873  	if (bfin_mac_hwtstamp_is_none(lp->stamp_cfg.rx_filter))
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  874  		return;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  875  
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17 @876  	valid = bfin_read_EMAC_PTP_ISTAT() & RXEL;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  877  	if (!valid)
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  878  		return;
fe92afed drivers/net/bfin_mac.c              Barry Song      2010-05-17  879  



---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
