From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] e100 in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 18:07:13 +0300
Message-ID: <549590A1.1050107@cogentembedded.com>
References: <000201d01c61$bdb956b0$392c0410$@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Linux-nics@isotope.jf.intel.com,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net
To: Jia-Ju Bai <baijiaju1990@163.com>, todd.fujinaka@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:39241 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbaLTPHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2014 10:07:17 -0500
Received: by mail-lb0-f174.google.com with SMTP id 10so2185661lbg.33
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2014 07:07:15 -0800 (PST)
In-Reply-To: <000201d01c61$bdb956b0$392c0410$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2014 5:32 PM, Jia-Ju Bai wrote:

> I am inexperienced in submitting patches, sorry.

    I see. It looks like you're failing to understand my English, too. :-(
    Please put such remarks under the --- line which should be placed after 
sign-off area.

> I have revised my patch:

    You still need to revise it some more.

> 1.Check whether pci_pool_create is failed in e100_probe to avoid null
> dereference in pci_pool_alloc(in e100_alloc_cbs).

    Please fix this issue by one (first) patch.

> 2.Add netif_napi_del to match the call of netif_napi_add.

    And fix this one by another (second) patch.
    Also, you need to insert empty line before sign-off.

> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

    ... and after sign-off too.

> diff --git a/drivers/net/ethernet/intel/e100.c
> b/drivers/net/ethernet/intel/e100.c
> index 781065e..a58ab2e 100644
[...]

   And finally, please re-post the patches in a new thread, not in reply to 
this (or other) thread.

WBR, Sergei
