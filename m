From: "Tom Lendacky" <toml@us.ibm.com>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Wed, 2 Apr 2003 09:00:03 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFFFFBD9B7.552E83C4-ON85256CFC.0051D199-86256CFC.00526741@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   "Hideaki YOSHIFUJI" <yoshfuji@cerberus.hongo.wide.ad.jp>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I just noticed the use of the AH_HLEN_NOICV #define which is hardcoded to
be 12.  The patch should probably take the change to the esp header and
apply it to the auth header also (as shown in an earlier post) and then
eliminate the hardcoding of the 12.

Thanks,
Tom
