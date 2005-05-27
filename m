From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 10:11:23 +1000
Message-ID: <20050527001123.GA16594@gondor.apana.org.au>
References: <468F3FDA28AA87429AD807992E22D07E056F6B37@orsmsx408> <20050526213421.GA8077@gondor.apana.org.au> <5fc59ff30505261608541b74fb@mail.gmail.com>
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
In-Reply-To: <5fc59ff30505261608541b74fb@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 26, 2005 at 04:08:17PM -0700, Ganesh Venkatesan wrote:
> 
> I do not get it. Bear with my ignorance.
> 
> e100_tx_timeout does not call e100_down. 
> 
> It is called from e100_tx_timeout_task which is invoked as a result of
> schedule_work. Are you saying that it would still not have the right
> context to call netif_disable_poll()?

Sorry, I was not aware that you've already added the sched work
in the driver.  With that it should work correctly.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
