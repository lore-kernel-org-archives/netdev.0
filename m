From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 10:20:56 +1000
Message-ID: <20050527002056.GA16644@gondor.apana.org.au>
References: <468F3FDA28AA87429AD807992E22D07E056F6B37@orsmsx408> <20050526213421.GA8077@gondor.apana.org.au> <5fc59ff30505261608541b74fb@mail.gmail.com> <20050527001123.GA16594@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        Andrew Morton <akpm@osdl.org>, Jian Jun He <hejianj@cn.ibm.com>,
        anton@samba.org, rende@cn.ibm.com,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, jgarzik@pobox.com,
        wangjs@cn.ibm.com, "Ronciak, John" <john.ronciak@intel.com>,
        cdlwangl@cn.ibm.com, linuxppc64-dev@lists.linuxppc.org.sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Content-Disposition: inline
In-Reply-To: <20050527001123.GA16594@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 27, 2005 at 10:11:23AM +1000, herbert wrote:
> 
> Sorry, I was not aware that you've already added the sched work
> in the driver.  With that it should work correctly.

BTW, I was just checking out your sched work code.  There needs
to be synchronisation between the tx_timeout task and the stop
method.  Otherwise they can race against each other or worse
tx_timeout could keep running even after stop has finished.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
