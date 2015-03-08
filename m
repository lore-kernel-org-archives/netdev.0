From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] route: label externally offloaded routes
Date: Sun, 08 Mar 2015 07:14:14 -0700
Message-ID: <54FC5936.5010100@cumulusnetworks.com>
References: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	jiri@resnulli.us
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:44800 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414AbbCHOOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 10:14:16 -0400
Received: by pdjz10 with SMTP id z10so37428097pdj.11
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 07:14:15 -0700 (PDT)
In-Reply-To: <1425795335-6416-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/15, 10:15 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> On ip route print dump, label externally offloaded routes with "external".
> Offloaded routes are flagged with RTNH_F_EXTERNAL, a recent additon to
> net-next.  For example:
>
> $ ip route
> default via 192.168.0.2 dev eth0
> 11.0.0.0/30 dev swp1  proto kernel  scope link  src 11.0.0.2 external
> 11.0.0.4/30 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
> 11.0.0.8/30 dev swp2  proto kernel  scope link  src 11.0.0.10 external
> 11.0.0.12/30 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
> 12.0.0.2  proto zebra  metric 30 external
>          nexthop via 11.0.0.1  dev swp1 weight 1
>          nexthop via 11.0.0.9  dev swp2 weight 1
> 12.0.0.3 via 11.0.0.1 dev swp1  proto zebra  metric 20 external
> 12.0.0.4 via 11.0.0.9 dev swp2  proto zebra  metric 20 external
> 192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

No objections to the patch.

since this is now getting exposed to userspace and there were 
suggestions in the past to use words like 'hw' or 'offload' in place of 
'external' here, checking to see if you are taking suggestions. If yes, 
would 'hw' or 'offloaded' be a better name for the flag ?.
Given that this will come up again for acls and such.

Thanks,
Roopa
