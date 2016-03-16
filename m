From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/6] bridge: add rtnl_lock in fdb_flush in
 br_sysfs_br.c
Date: Wed, 16 Mar 2016 14:55:46 +0100
Message-ID: <56E965E2.9050506@cumulusnetworks.com>
References: <cover.1458134414.git.lucien.xin@gmail.com>
 <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36617 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209AbcCPNzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 09:55:49 -0400
Received: by mail-wm0-f43.google.com with SMTP id l124so49699759wmf.1
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 06:55:49 -0700 (PDT)
In-Reply-To: <059d608901fd86407fed374e567c46447aa8c88f.1458134414.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/16/2016 02:34 PM, Xin Long wrote:
> In fdb_delete, it will send rtnl msg, so before that, we should
> hold rtnl_lock in the function that call it in sysfs.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/bridge/br_sysfs_br.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 

IIRC rtnl_notify() doesn't require rtnl lock to be held so this patch is not
needed
