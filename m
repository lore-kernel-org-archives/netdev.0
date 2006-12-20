From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 4/10] cxgb3 - HW access routines - part 2
Date: Wed, 20 Dec 2006 15:00:24 -0800
Message-ID: <4589C088.7020107@chelsio.com>
References: <200612201242.kBKCgaVU006331@localhost.localdomain> <1166623459.3365.1399.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:6193 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161001AbWLTXAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 18:00:41 -0500
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1166623459.3365.1399.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
>> +void t3_port_intr_disable(struct adapter *adapter, int idx)
>> +{
>> +	struct cphy *phy = &adap2pinfo(adapter, idx)->phy;
>> +
>> +	t3_write_reg(adapter, XGM_REG(A_XGM_INT_ENABLE, idx), 0);
>> +	phy->ops->intr_disable(phy);
>>     
>
> you seem to be missing a pci posting flush here....
>   
Thanks for catching this. Will fix.
