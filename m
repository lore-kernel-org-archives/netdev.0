From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/4] batman-adv: Use {} braces consistent on the arms of a statement
Date: Mon, 12 Mar 2012 13:16:43 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6E9D@saturn3.aculab.com>
References: <1331419491-21333-4-git-send-email-lindner_marek@yahoo.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <b.a.t.m.a.n@lists.open-mesh.org>,
	"Sven Eckelmann" <sven@narfation.org>
To: "Marek Lindner" <lindner_marek@yahoo.de>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50842 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755371Ab2CLNRo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 09:17:44 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23793-04 for <netdev@vger.kernel.org>;
 Mon, 12 Mar 2012 13:17:40 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1331419491-21333-4-git-send-email-lindner_marek@yahoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
> index 01b66d4..7f8e158 100644
> --- a/net/batman-adv/routing.c
> +++ b/net/batman-adv/routing.c
> @@ -237,8 +237,9 @@ int window_protected(struct bat_priv 
> *bat_priv, int32_t seq_num_diff,
>  				"old packet received, start
protection\n");
>  
>  			return 0;
> -		} else
> +		} else {
>  			return 1;
> +		}
>  	}
>  	return 0;
>  }

Doesn't this one fail on the "don't use 'else' after return/break" ?
Also look like it would read better if the condition (not quoted)
were inverted and the 'return 1' put first.

	David
