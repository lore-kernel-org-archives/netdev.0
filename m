From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH v3 0/2] refactor code and mark expected switch fall-throughs
Date: Fri, 27 Oct 2017 00:50:57 -0500
Message-ID: <cover.1509080630.git.garsilva@embeddedor.com>
References: <20171022203942.Horde.vHHdAHmZbpcBFTJEP0yIy9k@gator4166.hostgator.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Ralf Baechle <ralf@linux-mips.org>,
        walter harms <wharms@bfs.de>, Kevin Dawson <hal@kd.net.au>,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171022203942.Horde.vHHdAHmZbpcBFTJEP0yIy9k@gator4166.hostgator.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The aim of this patchset is firstly to refactor code in nr_route.c in order to make it
easier to read and maintain and, secondly, to mark some expected switch fall-throughs
in preparation to enabling -Wimplicit-fallthrough.

I have to mention that I did not implement any unit test.
If someone has any suggestions on how I could test this piece of code
it'd be greatly appreciated.

Thanks

Changes in v2:
 - Make use of the swap macro and remove inline keyword as suggested by
   Walter Harms and Kevin Dawson.

Changes in v3:
 - Update subject for both patches.
 - Add this cover letter as suggested by David Miller.

Gustavo A. R. Silva (2):
  net: netrom: nr_route: refactor code in nr_add_node
  net: netrom: nr_route: mark expected switch fall-throughs

 net/netrom/nr_route.c | 62 ++++++++++++++++-----------------------------------
 1 file changed, 19 insertions(+), 43 deletions(-)

-- 
2.7.4
