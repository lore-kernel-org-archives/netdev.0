From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next v2 0/9] xen-netback: TX grant mapping with SKBTX_DEV_ZEROCOPY
 instead of copy
Date: Wed, 8 Jan 2014 14:44:43 +0000
Message-ID: <52CD645B.6060700@citrix.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com> <20140108144324.GA6984@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jonathan.davies@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:2285 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756294AbaAHOpC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 09:45:02 -0500
In-Reply-To: <20140108144324.GA6984@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/14 14:43, Wei Liu wrote:
> You once mentioned that you have a trick to avoid touching TLB, is it in
> this series?
>
> (Haven't really looked at this series as I'm in today. Will have a
> closer look tonight. I'm just curious now.)
>
> Wei.
>
No, I'm currently working on that, it will be a separate series, as it 
also needs some Xen modifications which haven't reached upstream yet AFAIK.

Zoli
