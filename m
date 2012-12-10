From: Vipul Pandya <vipul@chelsio.com>
Subject: Re: [PATCH V3 1/5] cxgb4: Add T4 filter support
Date: Mon, 10 Dec 2012 15:16:23 +0530
Message-ID: <50C5AF6F.6080502@chelsio.com>
References: <1354533781-31575-1-git-send-email-vipul@chelsio.com> <1354533781-31575-2-git-send-email-vipul@chelsio.com> <20121203.140207.164096621247746195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"roland@purestorage.com" <roland@purestorage.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	Abhishek Agrawal <abhishek@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4205 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab2LJJqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 04:46:36 -0500
In-Reply-To: <20121203.140207.164096621247746195.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04-12-2012 00:32, David Miller wrote:
> From: Vipul Pandya <vipul@chelsio.com>
> Date: Mon,  3 Dec 2012 16:52:57 +0530
> 
>> +	/*
>> +	 * If the new or old filter have loopback rewriteing rules then we'll
>> +	 * need to free any existing Layer Two Table (L2T) entries of the old
>> +	 * filter rule.  The firmware will handle freeing up any Source MAC
>> +	 * Table (SMT) entries used for rewriting Source MAC Addresses in
>> +	 * loopback rules.
>> +	 */
>> +	if (f->l2t)
>> +		cxgb4_l2t_release(f->l2t);
>> +
>> +	/* The zeroing of the filter rule below clears the filter valid,
>> +	 * pending, locked flags, l2t pointer, etc. so it's all we need for
>> +	 * this operation.
>> +	 */
> 
> My greatest amusement is achieved when someone gets a code formatting
> rule both correct and wrong in the same patch, as you have done here.
> 
> Format comments in the networking:
> 
> 	/* Like
> 	 * this.
> 	 */
> 
> 	 /*
> 	  * Never,
> 	  * like this.
> 	  */
> 
> Thanks.
> 

I have submitted the series again making above changes. Thanks for
pointing out the same. I wonder how checkpatch.pl did not complain or
gave a warning for the incorrect commenting style. I corrected only
those comments for which checkpatch.pl gave me a warning. So, I think
there are some checks missing in checkpatch.pl script.

Thanks,
Vipul
