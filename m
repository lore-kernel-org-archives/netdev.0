From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Tue, 01 Apr 2003 14:07:27 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030401.140727.73666851.davem@redhat.com>
References: <1049234673.5116.11.camel@tomlt2.tomloffice.austin.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <1049234673.5116.11.camel@tomlt2.tomloffice.austin.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Tom Lendacky <toml@us.ibm.com>
   Date: 01 Apr 2003 16:04:32 -0600
   
   Please review and let me know if any changes are required.

Ok, now that I look at this I realize my suggestions from the other
day were wrong.

These expressions are huge, it's almost less readable.  Let's compact
this, by creating a struct named {ip,ipv6}_esp_header_no_enc_data.

How about that?
