From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes
Date: Mon, 31 Mar 2003 10:19:17 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030331.101917.85396623.davem@redhat.com>
References: <1049134030.1253.143.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1049134030.1253.143.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 31 Mar 2003 12:07:08 -0600

   Below is a patch for your consideration eliminating the use of some
   constants in the AH and ESP routines for IPv4 and IPv6.  I believe
   there was also a typo in a memcpy statement in net/ipv4/ah.c where
   iph->ihl was multiplied by 5 instead of 4.
   
Thanks a lot Tom, Applied.  Looks like not too many people have
been testing IPSEC links with IP options :-)

     - use sizeof ip(v6)_esp_hdr and substract the sizeof enc_data

This sounds the best.  It's a bit much to type, but it's the
most descriptive expression.
