From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] [TC/U32] Infrastructure for pretty printing
Date: Mon, 21 Apr 2008 13:52:38 +0200
Message-ID: <480C8006.3060708@trash.net>
References: <1208702964.12249.57.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38398 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755158AbYDULwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 07:52:43 -0400
In-Reply-To: <1208702964.12249.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
>  		case 0x0f000000:
> -			fprintf(f, "\n ihl %u", ntohl(key->val) >> 24);
> +			fprintf(f, "\n  match IP ihl %u", ntohl(key->val) >> 24);
>  			return;
>  		case 0x00ff0000:
> -			fprintf(f, "\n dsfield %#x", ntohl(key->val) >> 16);
> +			fprintf(f, "\n  match IP dsfield %#x", ntohl(key->val) >> 16);
>  			return;
>  		}

So far the dump output can be cut-and-pasted and is
properly parsed again (useful for example for deletion).
Does that still work with pretty printing?


