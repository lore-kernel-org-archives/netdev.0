From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: Pull request: SIOCGHWTSTAMP ioctl
Date: Fri, 6 Dec 2013 09:41:45 -0800
Message-ID: <52A20C59.2010705@caviumnetworks.com>
References: <1386286632.1516.120.camel@bwh-desktop.uk.level5networks.com>
	<20131205.194624.1335606571649336470.davem@davemloft.net>
	<1386351515.1516.156.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@redhat.com>, David Daney <david.daney@cavium.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>,
	netdev@vger.kernel.org, Takahiro Shimizu <tshimizu818@gmail.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1386351515.1516.156.camel@bwh-desktop.uk.level5networks.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 12/06/2013 09:38 AM, Ben Hutchings wrote:
> On Thu, 2013-12-05 at 19:46 -0500, David Miller wrote:
>> From: Ben Hutchings <bhutchings@solarflare.com>
>> Date: Thu, 5 Dec 2013 23:37:12 +0000
>>
>>> 1. Add the SIOCGHWTSTAMP ioctl and update the timestamping
>>> documentation.
>>> 2. Implement SIOCGHWTSTAMP in most drivers that support SIOCSHWTSTAMP.
>>> 3. Add a test program to exercise SIOC{G,S}HWTSTAMP.
>>
>> Pulled, thanks Ben.
>
> Thanks.  I hope all the drivers still work, as you didn't leave long for
> review.
>
> There are a few drivers I didn't touch because they don't appear to keep
> a soft copy of the timestamp configuration:
>
> drivers/net/ethernet/intel/igb/igb_main.c
> drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> drivers/net/ethernet/octeon/octeon_mgmt.c

I will look at modifying octeon_mgmt to support this.

Thanks,
David Daney


> drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>
> phylib and the dp83640 driver will also need to be updated to support
> this.
>
> Ben.
>


------------------------------------------------------------------------------
Sponsored by Intel(R) XDK 
Develop, test and display web and hybrid apps with a single code base.
Download it for free now!
http://pubads.g.doubleclick.net/gampad/clk?id=111408631&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
