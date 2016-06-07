From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH][RESEND] gtp: #define _UAPI_LINUX_GTP_H_ and not
 _UAPI_LINUX_GTP_H__
Date: Tue, 7 Jun 2016 12:33:19 +0200
Message-ID: <20160607103319.GA1527@salvia>
References: <1465225721-16371-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:57503 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771AbcFGKdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2016 06:33:25 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id D60A8499961
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 12:33:22 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C30E5266728
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 12:33:22 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id BC879266739
	for <netdev@vger.kernel.org>; Tue,  7 Jun 2016 12:33:20 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <1465225721-16371-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 06, 2016 at 04:08:41PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Fix clang build warning:
> 
> ./include/uapi/linux/gtp.h:1:9: warning: '_UAPI_LINUX_GTP_H_' is
> used as a header guard here, followed by #define of a different
> macro [-Wheader-guard]
> 
> fix by defining  _UAPI_LINUX_GTP_H_ and not _UAPI_LINUX_GTP_H__
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
