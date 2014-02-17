From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v2 3/3] Documentation: networking: update phy.txt
 with recent changes
Date: Tue, 18 Feb 2014 02:32:18 +0300
Message-ID: <53029C02.4020009@cogentembedded.com>
References: <1392672844-1767-1-git-send-email-f.fainelli@gmail.com> <1392672844-1767-4-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Shaohui.Xie@freescale.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:33645 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752968AbaBQWcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 17:32:21 -0500
Received: by mail-la0-f48.google.com with SMTP id mc6so11490938lab.7
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 14:32:19 -0800 (PST)
In-Reply-To: <1392672844-1767-4-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/18/2014 12:34 AM, Florian Fainelli wrote:

> The PHY library was missing a bunch of newly added PHY driver callbacks
> along with a smallish description of what they do, fix that.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
[...]

    Again too quick merge, not all types have been fixed. :-/

> diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
> index ebf2707..e602c6f 100644
> --- a/Documentation/networking/phy.txt
> +++ b/Documentation/networking/phy.txt
> @@ -253,16 +253,25 @@ Writing a PHY driver
>
>    Each driver consists of a number of function pointers:
[...]
> +   ts_info: Queries about the HW timestamping status
> +   hwtstamp: Set the PHY HW timestamping configuration
> +   rxtstamp: Requests a receive timestamp at the PHY level for a 'skb'
> +   txtsamp: Requests a transmit timestamp at the PHY level for a 'skb'

    s/txtsamp/txtstamp/.

WBR, Sergei
