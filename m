From: Tony Zelenoff <antonz@parallels.com>
Subject: Re: [PATCH rhel6] Allow ipv6 proxies and arp proxies be shown with
 iproute2
Date: Thu, 26 Jan 2012 19:03:39 +0400
Message-ID: <4F216B4B.20908@parallels.com>
References: <1327589392-10852-1-git-send-email-antonz@parallels.com>
Reply-To: <antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelianov <xemul@parallels.com>,
	"devel@openvz.org" <devel@openvz.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Anton Zelenov <antonz@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:36724 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751483Ab2AZPDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 10:03:48 -0500
In-Reply-To: <1327589392-10852-1-git-send-email-antonz@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Oops, sorry for subject. The "rhel6" shouldn't be here.
If it is a problem - i'll resend patch without this stuff.

On 26.01.2012 18:49, Anton Zelenov wrote:
> Add ability to return neighbour proxies list to caller if
> it sent full ndmsg structure and has NTF_PROXY flag set.
>
> Before this patch (and before iproute2 patches):
> $ ip neigh add proxy 2001::1 dev eth0
> $ ip -6 neigh show
> $
>
> After it and with applied iproute2 patches:
> $ ip neigh add proxy 2001::1 dev eth0
> $ ip -6 neigh show
> 2001::1 dev eth0  proxy
> $
>
> Compatibility with old versions of iproute2 is not broken,
> kernel checks for incoming structure size and properly
> works if old structure is came.
