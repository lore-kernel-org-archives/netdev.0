From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: IPv6 AH/ESP fixes
Date: Sat, 29 Mar 2003 04:12:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030329.041215.124919097.davem@redhat.com>
References: <1048870457.16800.5.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1048870457.16800.5.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 28 Mar 2003 10:54:16 -0600
   
   Below is a patch for your consideration for some AH/ESP problems
   that I encountered during tunnel mode testings.
   
   Please review and let me know if any changes are required.
   
Looks good, applied.
   
One comment:

   @@ -287,7 +287,7 @@
    	
    	x->props.header_len = XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV);
    	if (x->props.mode)
   -		x->props.header_len += 20;
   +		x->props.header_len += 40;
    	x->data = ahp;
    
    	return 0;

Yuck, let's get rid of these constants and use sizeof(ipv6_hdr) or
whatever this is supposed to me :-)
