From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] bridge: add vlan id to mdb notifications
Date: Wed, 26 Nov 2014 10:56:14 -0800
Message-ID: <20141126105614.6a42d697@urahara>
References: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, netdev@vger.kernel.org,
	wkok@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, sashok@cumulusnetworks.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:53845 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbaKZS40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2014 13:56:26 -0500
Received: by mail-pa0-f52.google.com with SMTP id eu11so3396896pac.11
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 10:56:25 -0800 (PST)
In-Reply-To: <1417010013-31454-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Nov 2014 05:53:33 -0800
roopa@cumulusnetworks.com wrote:

> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> index da17e45..db061fd 100644
> --- a/include/uapi/linux/if_bridge.h
> +++ b/include/uapi/linux/if_bridge.h
> @@ -185,6 +185,7 @@ struct br_mdb_entry {
>  			struct in6_addr ip6;
>  		} u;
>  		__be16		proto;
> +		__be16		vid;
>  	} addr;
>  };
>  

You can't add fields to existing binary API
