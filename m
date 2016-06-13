From: subashab@codeaurora.org
Subject: Re: [RFC] Handle error writing UINT_MAX to u32 fields
Date: Sun, 12 Jun 2016 20:30:46 -0600
Message-ID: <363ac4f6f7e1a8b905af567667a1559a@codeaurora.org>
References: <1465526452-30567-1-git-send-email-subashab@codeaurora.org>
 <575A5DF0.7020300@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Heinrich Schuchardt <xypron.glpk@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35245 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933106AbcFMCas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2016 22:30:48 -0400
In-Reply-To: <575A5DF0.7020300@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The suggested change would extend the usable range of positive numbers
> by one bit only. As many systems are 64 bit this does not seem forward
> looking.
> 
> I would prefer to have a routine that can handle 64 bit integers with
> limits (let's call it proc_doint64vec_minmax) which uses fields extra1
> and extra2 of ctl_table as min and max.
> 
> Then set xfrm_table[].extra1 = 0 and xfrm_table[].extra2 = UINT_MAX if
> you need a result in the u32 range.
> 

Thanks Heinrich. Do you think we can use proc_doulongvec_minmax for 
this?
