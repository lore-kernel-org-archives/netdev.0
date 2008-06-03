From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH]  Fix routing tables with id > 255 for legacy software
Date: Tue, 3 Jun 2008 08:08:12 +0000
Message-ID: <20080603080812.GA4514@ff.dom.local>
References: <48446fab.fEFxpuNLP1rSMKv2%olel@ans.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:15374 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbYFCIER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 04:04:17 -0400
Received: by fg-out-1718.google.com with SMTP id 19so969700fgg.17
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 01:04:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48446fab.fEFxpuNLP1rSMKv2%olel@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03-06-2008 00:09, Krzysztof Oledzki wrote:
> From 4cb8c341fc444afc638cf9ce4efb7e4248e88b5e Mon Sep 17 00:00:00 2001
> From: Krzysztof Piotr Oledzki <ole@ans.pl>
> Date: Tue, 3 Jun 2008 00:03:41 +0200
> Subject: [NET] Fix routing tables with id > 255 for legacy software
> 
> Most legacy software do not like tables > 255 as rtm_table is u8
> so tb_id is sent &0xff and it is possible to mismatch for example
> table 510 with table 254 (main).
> 
> This patch introduces RT_TABLE_COMPAT=253 so the code uses it if
> tb_id > 255. It makes such old applications happy, new
> ones are still able to use RTA_TABLE to get a proper table id.
> 

Probably, as usual, some people will grumble this breaks their scripts,
so, probably, some if or ifdef is needed? BTW, I wonder, how these old
appliction would treat RT_TABLE_UNSPEC instead.

Regards,
Jarek P.
