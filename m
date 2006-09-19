From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Fw: [PATCH] Remove powerpc specific parts of 3c509 driver
Date: Wed, 20 Sep 2006 09:18:38 +1000
Message-ID: <1158707918.6002.179.camel@localhost.localdomain>
References: <20060919145433.8fc7d478.sfr@canb.auug.org.au>
	<20060919184243.GL29167@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	ppc-dev <linuxppc-dev@ozlabs.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060919184243.GL29167@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


> However, I presume someone added the  __powerpc__ define here
> because they picked up a 3c509 at a garage sale, stuck it in 
> a powerpc, found out it didn't work due to a byte-swapping bug,
> and then patched it as above. I'm disturbed that somehow 
> outsl_ns() became identical to outsl() at some point, presumably
> breaking this patch.

The problem is that somebody had the "bright" idea to implement ppc
outsl as byteswapping a loooong time ago. This was totally bogus and got
fixed, but it looks like this driver holds a remain of that period.

Ben.
