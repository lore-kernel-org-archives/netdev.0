From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Tue, 01 Apr 2003 19:34:29 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030401.193429.64279267.davem@redhat.com>
References: <1049234673.5116.11.camel@tomlt2.tomloffice.austin.ibm.com>
	<20030401.140727.73666851.davem@redhat.com>
	<20030402.122518.62753078.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030402.122518.62753078.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 02 Apr 2003 12:25:18 +0900 (JST)

   In article <20030401.140727.73666851.davem@redhat.com> (at Tue, 01 Apr 2003 14:07:27 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:
   
   >    From: Tom Lendacky <toml@us.ibm.com>
   >    Date: 01 Apr 2003 16:04:32 -0600
   >    
   >    Please review and let me know if any changes are required.
   > 
   > Ok, now that I look at this I realize my suggestions from the other
   > day were wrong.
   > 
   > These expressions are huge, it's almost less readable.  Let's compact
   > this, by creating a struct named {ip,ipv6}_esp_header_no_enc_data.
   
   How about just removing 8 bytes from struct {ip,ipv6}_esp_hdr
   like this?
   
Sure, but does anyone need the 8 bytes there?  I thought so, which is
why I didn't think about your suggestion :-)
