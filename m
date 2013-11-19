From: Andrew Collins <bsderandrew@gmail.com>
Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Mon, 18 Nov 2013 17:01:05 -0700
Message-ID: <CAKTPYJTtE5wFaWQ3bR8KECt4N8sBnFW9PBVmGW-f-gRY_jzLEQ@mail.gmail.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
	<1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
	<20131107112549.GP31491@secunet.com>
	<527B8DC5.6080702@6wind.com>
	<1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Saurabh Mohan <saurabh.mohan@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:54248 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab3KSABH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 19:01:07 -0500
Received: by mail-vc0-f176.google.com with SMTP id ia6so3462532vcb.21
        for <netdev@vger.kernel.org>; Mon, 18 Nov 2013 16:01:06 -0800 (PST)
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC1273BA977C@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Getting rid of the pre-routing mark, which had to be done outside of
> the vti tunnel code was prone to misconfiguration.
> Though it is unfortunate that it creates a kernel version dependency.

Perhaps a section in the ip-link manpage for VTI describing the
expected configuration is worthwhile?

I quite like the functionality, especially since the pre-routing mark
removal, but I ended up having to read through commit logs to figure
out how to use it which is obviously non-ideal.
