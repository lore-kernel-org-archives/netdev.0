From: "Julius Volz" <juliusv@google.com>
Subject: Should we move IPVS out of net/ipv4 now?
Date: Wed, 17 Sep 2008 15:00:11 +0200
Message-ID: <f4845fc0809170600s28495494l128f7dd6f00e34e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "Simon Horman" <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Since IPVS now does partial IPv6, should we finally move it from
"net/ipv4/ipvs" to "net" or to "net/netfilter"? I posted that patch a
long time ago, but that was before any of the actual v6 features, so
there was probably no interest.

Also, the tunables in /proc/sys/net/ipv4/vs/... apply to both v4 and
v6. Should we just duplicate them into /proc/sys/net/ipv6/vs? Or will
people be confused that setting a value in one directory changes the
value in the other and affects both IP versions?

Julius

-- 
Julius Volz - Corporate Operations - SysOps

Google Switzerland GmbH - Identification No.: CH-020.4.028.116-1
