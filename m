From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Wed, 24 Jun 2009 09:43:36 -0700
Message-ID: <4A4257B8.2090105@hp.com>
References: <4A41961B.2090206@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:5136 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753125AbZFXQnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 12:43:35 -0400
In-Reply-To: <4A41961B.2090206@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Naohiro Ooiwa wrote:
> Hi Michael
> 
> I found a little bug.
> 
> When configure in ifcfg-eth* is ONBOOT=no,
> the behavior of ethtool command is wrong.
> 
>     # grep ONBOOT /etc/sysconfig/network-scripts/ifcfg-eth2
>     ONBOOT=no
>     # ethtool eth2 | tail -n1
>             Link detected: yes
> 
> I think "Link detected" should be "no".

Why?  Sure, there is no IP on the link, but does that mean the link is 
otherwise unusable?  Is ethtool only about IP status?

rick jones
