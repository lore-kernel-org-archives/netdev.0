From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH] iproute2: ip6_tunnel mode bugfixes: any,vti6
Date: Sun, 2 Nov 2014 11:49:17 -0800
Message-ID: <20141102114917.5529d99a@urahara>
References: <1414563570-9858-1-git-send-email-alan@al-an.info>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alexey Andriyanov <alan@al-an.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:17645 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751760AbaKBUWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 15:22:47 -0500
In-Reply-To: <1414563570-9858-1-git-send-email-alan@al-an.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Oct 2014 09:19:30 +0300
"Alexey Andriyanov" <alan@al-an.info> wrote:

> - any ipv6 tunnel mode (proto == 0) could not be set
> due to incomplete set of cases in do_add, do_del.
> - vti6 logic was inverted: it was using "ip6_vti0" basedev
> UNLESS mode is set to vti6.
> 
> We don't need a switch by p.proto in do_add()/do_del(): it
> already exists in parse_args(). So if parse_args() call
> was successful, no need to check tunnel mode again.
> 
> CC: Stephen Hemminger <shemming@brocade.com>
> Signed-off-by: Alexey Andriyanov <alan@al-an.info>

Accepted
