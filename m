From: Shruti Kanetkar <Shruti@freescale.com>
Subject: RE: [PATCH] net/phy: Remove return value for a void function
Date: Tue, 1 Apr 2014 19:53:52 +0000
Message-ID: <62eb4c507b904928a6b5891113153f18@DM2PR03MB365.namprd03.prod.outlook.com>
References: <1396363464-28923-1-git-send-email-Shruti@Freescale.com>
 <1396375445.21529.95.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Emilian Medve <Emilian.Medve@freescale.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.207] ([207.46.163.207]:23327 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751371AbaDAUKc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:10:32 -0400
In-Reply-To: <1396375445.21529.95.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Joe,

Thank you for sharing the script.
I shall give it a try and credit you for the script.

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Tuesday, April 01, 2014 1:04 PM
> To: Kanetkar Shruti-B44454
> Cc: f.fainelli@gmail.com; netdev@vger.kernel.org; Medve Emilian-EMMEDVE1
> Subject: Re: [PATCH] net/phy: Remove return value for a void function
> 
> Here's a spatch script for this:
> 
> $ cat void_return.cocci
> @@
> identifier func;
> expression S;
> @@
> void func(...) {
> ...
> 	if (...)
> -		return S;
> +		{ S; return; }
> ...
> }
> 
> @@
> identifier func;
> expression S;
> @@
> void func(...) {
> ...
> 	if (...) {
> ...
> -		return S;
> +		S;
> 	}
> ...
> }
> 
> @@
> identifier func;
> expression S;
> @@
> void func(...) {
> ...
> -	return S;
> +	S;
> }
> 
> 
> 

Regards,
Shruti
