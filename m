From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Re: IPSec: setkey -DP freezes machine
Date: Mon, 03 Mar 2003 04:19:50 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.041950.14411363.davem@redhat.com>
References: <20030303.013451.20307573.davem@redhat.com>
	<Pine.LNX.4.44.0303032238240.10142-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Pine.LNX.4.44.0303032238240.10142-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Mon, 3 Mar 2003 23:13:55 +1100 (EST)

   On Mon, 3 Mar 2003, David S. Miller wrote:
   
   >    Alternatively, a family parameter could be added to the compile_policy() 
   >    operation, but this duplicates data already present in our native 
   >    xfrm_userpolicy_info format.
   > 
   > I like this solution, it seems the cleanest.
   
   Ok, here's a patch which does this.
   
Looks good, I'll apply this.

If more problems are found, we can patch on top of this.
