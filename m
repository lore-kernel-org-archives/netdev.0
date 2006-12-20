From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH 4/10] cxgb3 - HW access routines - part 2
Date: Wed, 20 Dec 2006 15:04:19 +0100
Message-ID: <1166623459.3365.1399.camel@laptopd505.fenrus.org>
References: <200612201242.kBKCgaVU006331@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:37973 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965073AbWLTOE2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 09:04:28 -0500
To: divy@chelsio.com
In-Reply-To: <200612201242.kBKCgaVU006331@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +void t3_port_intr_disable(struct adapter *adapter, int idx)
> +{
> +	struct cphy *phy = &adap2pinfo(adapter, idx)->phy;
> +
> +	t3_write_reg(adapter, XGM_REG(A_XGM_INT_ENABLE, idx), 0);
> +	phy->ops->intr_disable(phy);

you seem to be missing a pci posting flush here....



-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

