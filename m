From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net-next 05/26] bfin_mac: Support the
 get_ts_info ethtool method.
Date: Fri, 06 Apr 2012 00:18:05 -0400 (EDT)
Message-ID: <20120406.001805.562264431747635985.davem@davemloft.net>
References: <cover.1333529504.git.richardcochran@gmail.com>
	<88e5b2cfcabda03826bb576b21e2e1d990f07117.1333529506.git.richardcochran@gmail.com>
	<CAP=VYLq1kCqLxi31HcGavKk8e3ydX43Xz-7rwayLJPWAnfk28Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: mporter@solarflare.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jacob.e.keller@intel.com,
	john.ronciak@intel.com, bhutchings@solarflare.com,
	linux-next@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CAP=VYLq1kCqLxi31HcGavKk8e3ydX43Xz-7rwayLJPWAnfk28Q@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 6 Apr 2012 00:08:52 -0400

> On Wed, Apr 4, 2012 at 4:59 AM, Richard Cochran
> <richardcochran@gmail.com> wrote:
>> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
>> ---
>> =A0drivers/net/ethernet/adi/bfin_mac.c | =A0 20 ++++++++++++++++++++
>> =A01 files changed, 20 insertions(+), 0 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/=
adi/bfin_mac.c
>> index ab4daec..db22278 100644
>> --- a/drivers/net/ethernet/adi/bfin_mac.c
>> +++ b/drivers/net/ethernet/adi/bfin_mac.c
>> @@ -548,6 +548,25 @@ static int bfin_mac_ethtool_setwol(struct net_devic=
e *dev,
>> =A0 =A0 =A0 =A0return 0;
>> =A0}
>>
>> +static int bfin_mac_ethtool_get_ts_info(struct net_device *dev,
>> + =A0 =A0 =A0 struct ethtool_ts_info *info);
> =

>    ----------------------------------->  ^^^^^^^
> =

> Trailing semicolon.  Compile fail in linux-next due to a85bbddd.

I just pushed out the obvious fix for this.

---------------------------------------------------------------------------=
---
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
