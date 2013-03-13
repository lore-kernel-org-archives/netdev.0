From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [iproute2] Fix -oneline output when alias present
Date: Wed, 13 Mar 2013 10:48:59 +0100
Message-ID: <20130313094859.GA3097@amd64.fatal.se>
References: <1363125827-14129-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h31.telenor.se ([213.150.131.4]:38110 "EHLO
	smtprelay-h31.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755506Ab3CMKP6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 06:15:58 -0400
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-h31.telenor.se (Postfix) with ESMTP id 515E3E97FC
	for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 10:45:26 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1363125827-14129-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Just wanted to point out some minor style issues with your patch.
See below...

On Tue, Mar 12, 2013 at 12:03:47PM -0000, roopa@cumulusnetworks.com wrote:
[...]
> -	if (do_link && tb[IFLA_IFALIAS])
> -		fprintf(fp,"\n    alias %s", 
> +	if (do_link && tb[IFLA_IFALIAS]) {
> +		fprintf(fp, "%s", _SL_);
> +		fprintf(fp,"    alias %s",

                          ^^^ missing space here.

Also, why not use a single fprintf?

Like:
                fprintf(fp, "%s    alias %s",
                        _SL_,
>  			rta_getattr_str(tb[IFLA_IFALIAS]));
> +	}

Then you wouldn't need these brackets either...

>  
>  	if (do_link && show_stats) {
>  		if (tb[IFLA_STATS64])

-- 
Andreas Henriksson
