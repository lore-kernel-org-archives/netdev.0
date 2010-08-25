From: Rasesh Mody <rmody@brocade.com>
Subject: RE: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Tue, 24 Aug 2010 21:22:19 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A4AE225EE8@HQ1-EXCH01.corp.brocade.com>
References: <20100825120927.c469ce20.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Jing Huang <huangj@Brocade.COM>,
	James Bottomley <James.Bottomley@HansenPartnership.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100825120927.c469ce20.sfr@canb.auug.org.au>
Content-Language: en-US
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All,

We are working on a fix and we will submit a patch soon.

Regards,
Rasesh

-----Original Message-----
From: Stephen Rothwell [mailto:sfr@canb.auug.org.au] 
Sent: Tuesday, August 24, 2010 7:09 PM
To: David Miller; netdev@vger.kernel.org
Cc: linux-next@vger.kernel.org; linux-kernel@vger.kernel.org; Rasesh Mody; Jing Huang; James Bottomley
Subject: linux-next: build failure after merge of the final tree (net tree related)

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/built-in.o: In function `bfa_ioc_is_operational':
(.opd+0x1c6c8): multiple definition of `bfa_ioc_is_operational'
drivers/scsi/built-in.o:(.opd+0x1b1b0): first defined here

and many more ...

Caused by commit 8b230ed8ec96c933047dd0625cf95f739e4939a6 ("bna: Brocade 10Gb Ethernet device driver") interacting with commit a whole series of patches to do with the Brocade BFA FC SCSI driver that are in Linus' tree stretching back to v2.6.32-rc2.

I have reverted that net tree commit (and commit
f04b4dd2b1f533cef0507e0410ffc6732d21a272 ("bna: Delete get_flags and set_flags ethtool methods") that depends on it).

--
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
