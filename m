From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [net-next]: unable to add routes to tables
Date: Wed, 19 Aug 2015 12:38:11 +0200
Message-ID: <55D45C93.7030509@tpip.net>
References: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net> <55D36AB7.3040005@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:38561 "EHLO mail.tpip.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314AbbHSKiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:38:14 -0400
In-Reply-To: <55D36AB7.3040005@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2015 07:26 PM, David Ahern wrote:
> On 8/18/15 10:57 AM, Andreas Schultz wrote:
>> Hi,
>>
>> It seems that the policy for adding routes to tables has changed between
>> Linux 4.2-rc6 and net-next.
>>
>> In Linux main line (tested up to 4.2-rc6), with this main routing table:
>> # ip route show table main
>> ...
>> 172.28.0.0/24 dev vnf-xe1p0  proto kernel  scope link  src 172.28.0.16
>>
>> and an empty table 100, this works:
>>
>> # ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
>>
>> With net-next at commit d52736e24fe2e927c26817256f8d1a3c8b5d51a0, the
>> same command leads to an:
>>
>> # ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
>> RTNETLINK answers: Resource temporarily unavailable
>>
>> Is this expected behavior?
>>
>
> The attached works for me and so does my original problem. Can you confirm it resolves your problem? If so I'll send a formal patch.

Seems to fix my problem, thanks.

Andreas
