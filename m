From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 1/3] xen-netback: move NAPI add/remove calls
Date: Fri, 08 Aug 2014 20:49:10 +0400
Message-ID: <53E4FF86.8040505@cogentembedded.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com> <1407515833-2550-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>, netdev@vger.kernel.org,
	xen-devel@lists.xen.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:37240 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757097AbaHHQtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2014 12:49:15 -0400
Received: by mail-la0-f45.google.com with SMTP id ty20so4883042lab.32
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2014 09:49:13 -0700 (PDT)
In-Reply-To: <1407515833-2550-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/08/2014 08:37 PM, Wei Liu wrote:

> Originally napi_add was in init_queue and napi_del was in deinit_queue,
> while kthreads were handled in _connect and _disconnect. Move napi_add
> and napi_remove

    netif_napi_{add|del}()?

 > to _connect and _disconnect so that they reside togother

    Together.

> with kthread operations.

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Zoltan Kiss <zoltan.kiss@citrix.com>

WBR, Sergei
