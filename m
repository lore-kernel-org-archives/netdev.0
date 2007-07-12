From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] Virtual ethernet device driver
Date: Thu, 12 Jul 2007 15:24:02 +0200
Message-ID: <46962B72.3070000@trash.net>
References: <4695F0BF.1000305@openvz.org> <4695F214.6020401@openvz.org> <46961F21.7030409@trash.net> <469629FD.4030709@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47044 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764302AbXGLNYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 09:24:24 -0400
In-Reply-To: <469629FD.4030709@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelianov wrote:
> Patrick McHardy wrote:
> 
>>>+
>>>+	if (tb[IFLA_IFNAME])
>>>+		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
>>>+	else
>>>+		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");
>>
>>
>>Does this work? The other device is not registered at this time, so I
>>think the allocated names could clash ..
> 
> 
> Oh! And one more thing, I've just thought about - even two devices with
> similar name would be ok when we have a namespaces and one of the ends of
> this tunnel is to be in some other namespace rather that the init one.


Yes, but we don't have network namespaces yet. Which brings up another
question: is this driver of any use without namespaces?

