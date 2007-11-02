From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 1/2][NETFILTER] Consolidate nf_sockopt and compat_nf_sockopt
Date: Fri, 02 Nov 2007 14:07:26 +0300
Message-ID: <472B04EE.6030705@openvz.org>
References: <4729F6F7.2020705@openvz.org> <472B02A1.40601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39188 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753005AbXKBLHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2007 07:07:55 -0400
In-Reply-To: <472B02A1.40601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelyanov wrote:
>> Both lookup the nf_sockopt_ops object to call the get/set callbacks
>> from, but they perform it in a completely similar way.
>>
>> Introduce the helper for finding the ops.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org >
> 
> 
> This conflicts with a cleanup patch from Alexey Dobriyan. I'll
> push it upstream today, please resend after rediffing. Thanks.
> 

Amazing :) Alexey's patch does the same thing as my 2nd
one does :) I will resend this one :)

Thanks,
Pavel
