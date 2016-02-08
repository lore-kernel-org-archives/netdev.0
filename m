From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] iplink: bond_slave: fix
 ad_actor/partner_oper_port_state output
Date: Mon, 8 Feb 2016 21:56:32 +0100
Message-ID: <56B90100.6@cumulusnetworks.com>
References: <1454948038-1090-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stannous@cumulusnetworks.com, roopa@cumulusnetworks.com,
	stephen@networkplumber.org
To: Nikolay Aleksandrov <razor@blackwall.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:33122 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755218AbcBHU4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 15:56:35 -0500
Received: by mail-wm0-f42.google.com with SMTP id g62so149529778wme.0
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 12:56:35 -0800 (PST)
In-Reply-To: <1454948038-1090-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2016 05:13 PM, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> It seems that I've made a mistake when I exported these, instead of a
> space in the end I've put a newline character which is wrong and breaks
> the single line output.
> 
> Fixes: 7d6bc3b87abad ("bonding: export 3ad actor and partner port state")
> Reported-by: Sam Tannous <stannous@cumulusnetworks.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  ip/iplink_bond_slave.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 

I'm not sure if this patch is appropriate as there might be scripts that already
parse it like this (with newline at the end). So if it's not acceptable I can suggest
a different approach where iplink_bond_slave will account for the "oneline" argument
and only then print it with a space so people will have an option. But currently
this breaks the one line "way" of printing that all other iplink users are doing.
