From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net-next 2/5] qede: Add support for ethtool private flags
Date: Mon, 18 Apr 2016 14:34:53 +0000
Message-ID: <CO2PR11MB0088E75B42A5F0901ED99CB1976B0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1460921195-23352-1-git-send-email-Yuval.Mintz@qlogic.com>
 <1460921195-23352-3-git-send-email-Yuval.Mintz@qlogic.com>,<5714EB23.5020102@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0127.outbound.protection.outlook.com ([65.55.169.127]:51826
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750860AbcDROtD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 10:49:03 -0400
In-Reply-To: <5714EB23.5020102@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +     flags |= (!!(edev->dev_info.common.num_hwfns > 1)) <<
>> +              QEDE_PRI_FLAG_CMT;

>  Why not just '='?

>> +
>> +     return flags;

>  ... or direct return of the value above?

Probably wanted to lay the basis for future flags.
But you're right in that there's no need for it.
I'll change it in V2.

Thanks,
Yuval
