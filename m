From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next  13/18] liquidio support for new device cn23xx
Date: Thu, 4 Aug 2016 16:04:53 +0000
Message-ID: <CO2PR11MB00888557E33988EFF458C38A97070@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470250549-10993-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <1470250549-10993-14-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0091.outbound.protection.outlook.com ([104.47.42.91]:4832
	"EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758792AbcHDQE4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 12:04:56 -0400
In-Reply-To: <1470250549-10993-14-git-send-email-rvatsavayi@caviumnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void cn23xx_bar1_idx_setup(struct octeon_device *oct, u64 core_addr,
...
> +	if (valid == 0) {
!valid

...
> +		WRITE_ONCE(bar1, lio_pci_readq(
> +		    oct, CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx)));
> +		lio_pci_writeq(oct, (READ_ONCE(bar1) & 0xFFFFFFFEULL),
> +			       CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port,
> idx));
> +		WRITE_ONCE(bar1, lio_pci_readq(
> +		    oct, CN23XX_PEM_BAR1_INDEX_REG(oct->pcie_port, idx)));
Indentation issues?

> +static u32 cn23xx_update_read_index(struct octeon_instr_queue *iq) {
...
> +	/* reset the cnt as a part of napi enable interrupt or check_iq_db */
> +	/*writeq(pkt_in_done | CN23XX_INTR_RESEND, iq->inst_cnt_reg);*/
Looks like this comment should be removed.
