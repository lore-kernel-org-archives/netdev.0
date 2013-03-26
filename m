From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2 net-next 08/12] 6lowpan: store fragment tag values
 per device instead of net stack wide
Date: Tue, 26 Mar 2013 16:38:15 +0400
Message-ID: <515196B7.2010507@cogentembedded.com>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org> <1364270372-19430-9-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:37410 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759528Ab3CZMjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 08:39:18 -0400
Received: by mail-la0-f42.google.com with SMTP id fe20so13493405lab.1
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 05:39:16 -0700 (PDT)
In-Reply-To: <1364270372-19430-9-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 26-03-2013 7:59, Tony Cheneau wrote:

> Signed-off-by: Tony Cheneau <tony.cheneau@amnesiak.org>
> ---
>   net/ieee802154/6lowpan.c | 9 +++++----
>   1 file changed, 5 insertions(+), 4 deletions(-)

> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 61eee9d..f952451 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -104,6 +104,7 @@ static const u8 lowpan_llprefix[] = {0xfe, 0x80};
>   struct lowpan_dev_info {
>   	struct net_device	*real_dev; /* real WPAN device ptr */
>   	struct mutex		dev_list_mtx; /* mutex for list ops */
> +	unsigned short fragment_tag;

    Small formatting nit: align field name with the others above please.

WBR, Sergei
