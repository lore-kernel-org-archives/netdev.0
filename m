From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec: Policy dst bundles exhausting storage
Date: Tue, 17 Jun 2003 11:43:46 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617.114346.94556992.davem@redhat.com>
References: <OF5E3AE43A.9C52FDB9-ON86256D48.0064B1C4-86256D48.0066613A@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com
In-Reply-To: <OF5E3AE43A.9C52FDB9-ON86256D48.0064B1C4-86256D48.0066613A@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Tom Lendacky" <toml@us.ibm.com>
   Date: Tue, 17 Jun 2003 13:38:15 -0500

   In __xfrm6_bundle_create, rt0->rt6i_src address and prefix length
   are zero (as well as rt->rt6i_src)

That's perfectly fine, a 0-length prefix will cause a matche
on all addresses.
