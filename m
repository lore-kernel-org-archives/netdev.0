From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/1] net: ppp: access ppp->nextseq only if CONFIG_PPP_MULTILINK
 is defined
Date: Thu, 17 Jul 2014 01:48:32 +0400
Message-ID: <53C6F330.3050602@cogentembedded.com>
References: <53C6F186.30809@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, Paul Mackerras <paulus@samba.org>
To: Christoph Schulz <develop@kristov.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:34884 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752648AbaGPVsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:48:33 -0400
Received: by mail-la0-f52.google.com with SMTP id e16so1118740lan.11
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 14:48:31 -0700 (PDT)
In-Reply-To: <53C6F186.30809@kristov.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 07/17/2014 01:41 AM, Christoph Schulz wrote:

> From: Christoph Schulz <develop@kristov.de>

> Commit d762d038497c9df51c19fcbe69b094b3bf8e5568 resets the counter holding the

    Please also specify that commit's summary line in parens.

> next sequence number for multilink PPP fragments to zero whenever the
> SC_MULTILINK flag is set. However, this counter only exists if
> CONFIG_PPP_MULTILINK is defined. Consequently, the new code has to be enclosed
> within #ifdef CONFIG_PPP_MULTILINK ... #endif.

> Signed-off-by: Christoph Schulz <develop@kristov.de>

WBR, Sergei
