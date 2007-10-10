From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] IPoIB: Fix unused variable warning
Date: Tue, 09 Oct 2007 20:32:24 -0400
Message-ID: <470C1D98.6010308@garzik.org>
References: <20071009.135145.95506679.davem@davemloft.net>	<adahckzhprc.fsf@cisco.com>	<adad4vnhpoq.fsf_-_@cisco.com> <20071009.161750.02298910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33344 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbXJJAc1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:32:27 -0400
In-Reply-To: <20071009.161750.02298910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Roland Dreier <rdreier@cisco.com>
> Date: Tue, 09 Oct 2007 15:46:13 -0700
> 
>> The conversion to use netdevice internal stats left an unused variable
>> in ipoib_neigh_free(), since there's no longer any reason to get
>> netdev_priv() in order to increment dropped packets.  Delete the
>> unused priv variable.
>>
>> Signed-off-by: Roland Dreier <rolandd@cisco.com>
> 
> Jeff, do you want to merge in Roland's 4 patches to your tree then do
> a sync with me so I can pull it all in from you?

Grabbing them now...


