From: Tony Prisk <linux@prisktech.co.nz>
Subject: Re: [PATCHv2 0/3] Add support for velocity network driver on platform
 devices
Date: Tue, 30 Apr 2013 07:19:02 +1200
Message-ID: <517EC7A6.9030204@prisktech.co.nz>
References: <1367221841-14563-1-git-send-email-linux@prisktech.co.nz> <20130429.151528.2251094691456287740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	vt8500-wm8505-linux-kernel@googlegroups.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.prisktech.co.nz ([115.188.14.127]:65123 "EHLO
	server.prisktech.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932386Ab3D2TS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:18:59 -0400
In-Reply-To: <20130429.151528.2251094691456287740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/13 07:15, David Miller wrote:
> You prepared these patches against a net-next tree which is at least
> a week old, I know this because that's when the NETIF_F_* flags for
> VLAN offloading changed their names which causes your third patch
> to fail to apply.
>
> Do not do this, net-next changes every day and rapidly, don't take
> the chance that the driver you're touching is unpopular and thus
> hasn't had changes to it recently.  Tree-wide interface changes
> happen all the time.
Apologies - I didn't realise. These patches are based against 3.8-rc8.
I will rebase against net-next and resend.

Regards
Tony P
