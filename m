From: David Decotigny <decot@google.com>
Subject: dl2k/stmmac patches (was Re: [PATCH 2/2] net/dl2k: Don't reconfigure
 link @100Mbps when disabling autoneg @1Gbps)
Date: Fri, 13 May 2011 08:54:18 -0700
Message-ID: <4DCD542A.4010904@google.com>
References: <1304986748-15809-1-git-send-email-decot@google.com>	<1304986748-15809-3-git-send-email-decot@google.com> <82y62dk1qz.fsf@mid.bfk.de>
Reply-To: david@decotigny.fr
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Weimer <fweimer@bfk.de>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <82y62dk1qz.fsf@mid.bfk.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1


Hi all,

An update on the patch series I posted earlier (dl2k/stmmac autoneg
minor changes: see my posts on 05/09/11 17:19 PST)...

I'd suggest dropping the patch concerning dl2k, as I don't have any way
to claim it's any good at all (though I'm pretty confident it doesn't
make things any worse).

However, for the other patch of the same series (stmmac), please
consider for inclusion the new version prepared by Giuseppe instead of
my initial patch, for his version readily integrates my patch and has
been tested on real hardware:
  stmmac: don't go through ethtool to start auto-negotiation
  stmmac: fix autoneg in set_pauseparam

Regards,
Thank you!

On 05/11/11 02:47, Florian Weimer wrote:
> * David Decotigny:
> 
>> Tested: module compiling, NOT tested on real hardware.
> 
> To my knowledge, dl2k is broken.  Some sort of synchronization
> primitives are missing.  Under load, the NIC's notion of ring buffer
> status diverges from the host's view. 8-(
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk3NVCYACgkQld7vhusVrCHUEACggeKyCmoEHy9AzYec/aW8cDjU
GyAAoIiESxUAFWuKBmCOA31X/V0fvC+Y
=6hXY
-----END PGP SIGNATURE-----
