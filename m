From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 02/15] [ATM]: Use proc_create() to setup ->proc_fops first
Date: Fri, 29 Feb 2008 13:23:45 +0800
Message-ID: <47C796E1.7030203@cn.fujitsu.com>
References: <47C6931B.70204@cn.fujitsu.com> <20080228.135611.252555298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52575 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750745AbYB2F0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Feb 2008 00:26:22 -0500
In-Reply-To: <20080228.135611.252555298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller said the following on 2008-2-29 5:56:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Thu, 28 Feb 2008 18:55:23 +0800
> 
>> Use proc_create() to make sure that ->proc_fops be setup before gluing
>> PDE to main tree.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Applied, thanks.
> 
> Some of those paths could definitely use some error
> handling.
> 

Thanks Dave, I will make patch for error handling later.

