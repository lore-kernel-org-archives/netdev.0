From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [net-next]: unable to add routes to tables
Date: Tue, 18 Aug 2015 11:05:51 -0600
Message-ID: <55D365EF.9040106@cumulusnetworks.com>
References: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Andreas Schultz <aschultz@tpip.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:36254 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753358AbbHRRF4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 13:05:56 -0400
Received: by iodv127 with SMTP id v127so181094531iod.3
        for <netdev@vger.kernel.org>; Tue, 18 Aug 2015 10:05:56 -0700 (PDT)
In-Reply-To: <1029376325.2912846.1439917035503.JavaMail.zimbra@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/18/15 10:57 AM, Andreas Schultz wrote:
> Hi,
>
> It seems that the policy for adding routes to tables has changed between
> Linux 4.2-rc6 and net-next.
>
> In Linux main line (tested up to 4.2-rc6), with this main routing table:
> # ip route show table main
> ...
> 172.28.0.0/24 dev vnf-xe1p0  proto kernel  scope link  src 172.28.0.16
>
> and an empty table 100, this works:
>
> # ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
>
> With net-next at commit d52736e24fe2e927c26817256f8d1a3c8b5d51a0, the
> same command leads to an:
>
> # ip route add 10.0.0.0/8 via 172.28.0.32 table 100 dev vnf-xe1p0
> RTNETLINK answers: Resource temporarily unavailable
>
> Is this expected behavior?

That's going to be due to 3bfd847203c6d89532f836ad3f5b4ff4ced26dd9.

I'll fix.

David
