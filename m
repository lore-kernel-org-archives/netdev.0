From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip_vti: remove the useless err_count check in
 vti_xmit
Date: Wed, 01 Nov 2017 11:57:59 +0900 (KST)
Message-ID: <20171101.115759.2153401916473768067.davem@davemloft.net>
References: <b28eef283ea7622e74a930cc708489fa9c1139c7.1509191181.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, saurabh.mohan@vyatta.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44412 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdKAC6B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:58:01 -0400
In-Reply-To: <b28eef283ea7622e74a930cc708489fa9c1139c7.1509191181.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 28 Oct 2017 19:46:21 +0800

> Unlike ipip and gre, ip_vti never uses err_count in vti4_err,
> so no need to check err_count in vti_xmit, it's value always 0.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
