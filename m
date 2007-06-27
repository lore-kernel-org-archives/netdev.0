From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Devel] Re: [RFD] L2 Network namespace infrastructure
Date: Wed, 27 Jun 2007 16:45:33 +0200
Message-ID: <4682780D.1060303@trash.net>
References: <m1tzszbwyb.fsf@ebiederm.dsl.xmission.com> <467CF8AC.80103@trash.net> <468276BA.7020309@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jeff Garzik <jeff@garzik.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Linux Containers <containers@lists.osdl.org>,
	Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Kirill Korotaev <dev@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58611 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbXF0Oqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 10:46:49 -0400
In-Reply-To: <468276BA.7020309@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev wrote:
> Patrick McHardy wrote:
>   
>>
>>
>> I believe OpenVZ stores the current namespace somewhere global,
>> which avoids passing the namespace around. Couldn't you do this
>> as well?
>>     
>
> yes, we store a global namespace context on current
> (can be stored in per-cpu as well).
>
> do you prefer this way?

I'm not sure, it would avoid passing it around everywhere, but I'd
expect it to be harder to review because you can't simply follow it
as it gets passed around.


