From: Richard Gregory <R.Gregory@liverpool.ac.uk>
Subject: Re: r8169+NAPI soft lockup
Date: Tue, 09 May 2006 19:17:19 +0100
Message-ID: <4460DCAF.7060503@liv.ac.uk>
References: <4460B8DC.9080105@liv.ac.uk> <20060509164335.GA807@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.liv.ac.uk ([138.253.100.181]:28035 "EHLO mx3.liv.ac.uk")
	by vger.kernel.org with ESMTP id S1750884AbWEISRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 14:17:21 -0400
Received: from mailhubb.liv.ac.uk ([138.253.100.37])
	by mx3.liv.ac.uk with esmtp (Exim 4.54)
	id 1FdWls-0003Db-Dl
	for netdev@vger.kernel.org; Tue, 09 May 2006 19:17:20 +0100
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060509164335.GA807@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Richard Gregory <R.Gregory@liverpool.ac.uk> :
> 
>>I'm seeing the crash below using 2.6.16.11 custom based on RedHat FC2. 
>>The main culprit being the r8169+NAPI module, although the it821x module 
>>(with noraid=1) seems to bring out the bug, maybe because it uses the 
>>same interrupt.
> 
> 
> (lot of things to digest...)
> 
> Is netconsole enabled ?

It can be. How much output do you need, a single soft lockup?


Richard
