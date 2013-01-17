From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 4/7] net/mlx4_en: Set carrier to off when a port
 is stopped
Date: Thu, 17 Jan 2013 09:04:08 +0200
Message-ID: <50F7A268.1090708@mellanox.com>
References: <1358350935-3281-1-git-send-email-amirv@mellanox.com>  <1358350935-3281-5-git-send-email-amirv@mellanox.com> <1358352016.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:47395 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759191Ab3AQHDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 02:03:35 -0500
In-Reply-To: <1358352016.2923.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/01/2013 18:00, Ben Hutchings wrote:
> On Wed, 2013-01-16 at 17:42 +0200, Amir Vadai wrote:
>> >From: Eugenia Emantayev<eugenia@mellanox.com>
>> >
>> >Under heavy CPU load changing ring size/mtu/etc. could result in transmit
>> >timeout, since stop-start port might take more than 10 sec. Set
>> >netif_carrier_off to prevent tx queue transmit timeout.
> A spurious link change can restart L3 auto-configuration (DHCP, SLAAC,
> etc.)  netif_device_detach() also inhibits the watchdog and doesn't have
> that problem.
>
> Ben.
>

Thanks, Ben.

I will change it to netif_device_attach().
Since this will need some testing, will resend the patchset without this 
patch for now.

Amir.
