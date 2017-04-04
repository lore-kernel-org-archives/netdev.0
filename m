From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] selftests: add a generic testsuite for ethernet device
Date: Tue, 4 Apr 2017 17:00:30 +0200
Message-ID: <20170404150030.GF1736@lunn.ch>
References: <20170404133247.28725-1-clabbe.montjoie@gmail.com>
 <8f363cf9-1696-bab9-ab54-a003541e1409@axis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Corentin Labbe <clabbe.montjoie@gmail.com>, shuah@kernel.org,
        davem@davemloft.net, linux-kselftest@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Niklas Cassel <niklas.cassel@axis.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8f363cf9-1696-bab9-ab54-a003541e1409@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 04, 2017 at 04:43:19PM +0200, Niklas Cassel wrote:
> On 04/04/2017 03:32 PM, Corentin Labbe wrote:
> > This patch add a generic testsuite for testing ethernet network device driver.
> > 
> > Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
> > ---
> > 
> > Changes since v1:
> > - Test for starting master interface
> > - Changed printing format to "RESULT: $netdev: line"
> > - Use "ip link" to get device list
> > 
> >  tools/testing/selftests/net/Makefile     |   2 +-
> >  tools/testing/selftests/net/netdevice.sh | 200 +++++++++++++++++++++++++++++++
> >  2 files changed, 201 insertions(+), 1 deletion(-)
> >  create mode 100755 tools/testing/selftests/net/netdevice.sh
> > 
> (snip)
> 
> Good work!
> 
> I suggest adding a test for setting MTU as well.

That one might be tricky. Some devices don't allow the MTU to be
changed when the device is up. Others might require the interface is
up...

	Andrew
