From: "Tom Lendacky" <toml@us.ibm.com>
Subject: Re: [PATCH] Re: IPSec: setkey -DP freezes machine
Date: Mon, 3 Mar 2003 09:37:37 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFBF1A69FC.8A35D98E-ON86256CDE.0055736B-86256CDE.0055D7BC@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Ok, here's a patch which does this.
>
> I've also added check to verify_newpolicy_info() so that we don't run
into
> the same problem for policies provided via the netlink interface.
>
> Tom, would you let me know if this works for you, as my racoon isn't
> working yet.

The patch works for me, setkey -DP no longer freezes the machine and the
proper output is displayed.

Tom
