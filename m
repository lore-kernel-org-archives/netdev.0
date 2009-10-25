From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Sun, 25 Oct 2009 21:17:14 +0100
Message-ID: <20091025201714.GA20987@nuttenaction>
References: <200910252158.53921.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:51111 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752327AbZJYUXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 16:23:55 -0400
Content-Disposition: inline
In-Reply-To: <200910252158.53921.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Octavian Purdila | 2009-10-25 21:58:53 [+0200]:

>
>The current dev_name_hash is not very good at spreading entries when a
>large number of interfaces of the same type (e.g. ethXXXXX) are used.
>
>Here are some performance numbers for creating 16000 dummy interfaces with
>and without the patch (with per device sysctl entries disabled)
>
>    With patch                      Without patch
>
>    real    0m 2.27s                real    0m 4.32s
>    user    0m 0.00s                user    0m 0.00s
>    sys     0m 1.13s                sys     0m 2.16s

Can you rerun the test with jhash() as the hash function? Just for clearness -
the spreading of jhash should be more uniformly distributed. At the end: where
is the threshold where a more accurate hash function is superior.

HGN

-- 
Hagen Paul Pfeifer <hagen@jauu.net>  ||  http://jauu.net/
Telephone: +49 174 5455209           ||  Key Id: 0x98350C22
Key Fingerprint: 490F 557B 6C48 6D7E 5706 2EA2 4A22 8D45 9835 0C22
