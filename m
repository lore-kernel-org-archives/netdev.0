From: Vladimir Zapolskiy <vz@mleia.com>
Subject: Re: [PATCH] dm9000: control debug level of the driver
Date: Fri, 19 Aug 2011 23:26:41 +0300
Message-ID: <4E4EC701.4020607@mleia.com>
References: <1313426314-6422-1-git-send-email-vz@mleia.com> <20110818.220902.1663745747317150778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben-linux@fluff.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li271-223.members.linode.com ([178.79.152.223]:46319 "EHLO
	mail.mleia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756278Ab1HSU1D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 16:27:03 -0400
In-Reply-To: <20110818.220902.1663745747317150778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19.08.2011 08:09, David Miller wrote:
> From: Vladimir Zapolskiy<vz@mleia.com>
> Date: Mon, 15 Aug 2011 19:38:34 +0300
>
>> This change allows to get driver specific debug messages output
>> setting a default value for db->debug_level. As far as the maximum
>> level of verbosity is too high, it is demoted by default.
>>
>> Signed-off-by: Vladimir Zapolskiy<vz@mleia.com>
>> Cc: Ben Dooks<ben-linux@fluff.org>
>
> I would much rather see this config option eliminated entirely.
>
> The default can be set by the user at kernel boot or module
> load time with command line settings.

This definitely should be an improvement, initially I wanted to fix a 
particular problem, but let's do it even better.

--
With best wishes,
Vladimir
