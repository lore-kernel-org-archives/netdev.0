From: Brad Johnson <bjohnson@ecessa.com>
Subject: Re: [PATCH net] vti: get rid of nf mark rule in prerouting
Date: Fri, 02 May 2014 08:57:48 -0500
Message-ID: <5363A45C.1000205@ecessa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39313 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbaEBN5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 09:57:54 -0400
Received: by mail-ie0-f174.google.com with SMTP id ar20so5092906iec.19
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 06:57:54 -0700 (PDT)
Received: from [192.168.2.92] (mail.ecessa.com. [173.160.121.97])
        by mx.google.com with ESMTPSA id g1sm6837896igt.14.2014.05.02.06.57.53
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 06:57:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When strongSwan is configured this way with mark values, the SA's and 
the SP's are configured with the mark. I can get this to work by 
manually deleting and re-adding the ip xfrm state without the mark after 
strongSwan connects. But is there any easier way to force the creation 
of the xfrm state with the "wildcard" mark (i.e. with no mark)?

Thanks,
Brad Johnson

 > -----Original Message-----
 > From: Christophe Gouault [mailto:christophe.gouault@xxxxxxxxx]
 > Sent: Tuesday, October 08, 2013 8:21 AM
 > To: netdev@xxxxxxxxxxxxxxx
 > Cc: David S. Miller; Cong Wang; Saurabh Mohan; Christophe Gouault
 > Subject: [PATCH net] vti: get rid of nf mark rule in prerouting
 >
 > This patch fixes and improves the use of vti interfaces (while 
lightly changing
 > the way of configuring them).
 >

> SAs have a wildcard mark.
> SPs have a mark equal to the vti interface o_key.
