From: "David S. Miller" <davem@redhat.com>
Subject: Re: Flow cache flush oops
Date: Thu, 19 Jun 2003 12:11:08 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619.121108.21920417.davem@redhat.com>
References: <OFF5CE2037.3D4C9104-ON86256D49.007EAEAD-86256D49.007F5519@pok.ibm.com>
	<20030619000704.GA25135@gondor.apana.org.au>
	<20030619093518.GA27025@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: toml@us.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20030619093518.GA27025@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Herbert Xu <herbert@gondor.apana.org.au>
   Date: Thu, 19 Jun 2003 19:35:18 +1000

   Here is the patch.

Applied, thanks Herbert.

Reviewing this made me notice that we don't check the
__get_free_pages() return value.  I'll fix that.

Thanks again.
