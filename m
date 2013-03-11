From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: Allow for backward compatibility with
 new VPD scheme.
Date: Mon, 11 Mar 2013 11:21:51 +0530
Message-ID: <513D70F7.4090708@chelsio.com>
References: <1362749729-4532-1-git-send-email-vipul@chelsio.com> <20130308.124411.445253877641244372.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Abhishek Agrawal <abhishek@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14650 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab3CKFv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 01:51:57 -0400
In-Reply-To: <20130308.124411.445253877641244372.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08-03-2013 23:14, David Miller wrote:
> From: Vipul Pandya <vipul@chelsio.com>
> Date: Fri,  8 Mar 2013 19:05:29 +0530
> 
>> From: Santosh Rastapur <santosh@chelsio.com>
>>
>> New scheme calls for 3rd party VPD at offset 0x0 and Chelsio VPD at offset
>> 0x400 of the function.  If no 3rd party VPD is present, then a copy of
>> Chelsio's VPD will be at offset 0x0 to keep in line with PCI spec which
>> requires the VPD to be present at offset 0x0.
>>
>> Signed-off-by: Santosh Rastapur <santosh@chelsio.com>
>> Signed-off-by: Vipul Pandya <vipul@chelsio.com>
> 
> Isn't this a fix which is better targetted at 'net' than 'net-next'?
> 

We have very soon new patch series coming up for net-next. This patch
requires for that patch series to work correctly. So, we would like to
get this merge in net-next tree.

Thanks,
Vipul
