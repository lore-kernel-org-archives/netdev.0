From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 11:26:26 +1000
Message-ID: <20050527012626.GA17294@gondor.apana.org.au>
References: <468F3FDA28AA87429AD807992E22D07E056F70D4@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>,
        Andrew Morton <akpm@osdl.org>, Jian Jun He <hejianj@cn.ibm.com>,
        anton@samba.org, rende@cn.ibm.com,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, jgarzik@pobox.com,
        wangjs@cn.ibm.com, "Ronciak, John" <john.ronciak@intel.com>,
        cdlwangl@cn.ibm.com, linuxppc64-dev@lists.linuxppc.org.sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E056F70D4@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 26, 2005 at 05:28:55PM -0700, Venkatesan, Ganesh wrote:
> Would adding flush_sheduled_tasks() to e100_down, do it?

Even though it might be OK it's probably not a good idea to have
the task flush itself while it's running.

If you put it in the e100_close function then it should be fine.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
