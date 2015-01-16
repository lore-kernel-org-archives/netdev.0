From: Xander Huff <xander.huff@ni.com>
Subject: Re: [PATCH RESEND] igb: Reset TXPBSIZE to default
	value
Date: Fri, 16 Jan 2015 14:09:54 -0600
Message-ID: <54B97012.4050402@ni.com>
References: <1421434779-20586-1-git-send-email-xander.huff@ni.com>
	<D0DEA929.671EB%matthew.vick@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "jeff.westfahl@ni.com" <jeff.westfahl@ni.com>,
	"e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linux NICS <Linux-nics@isotope.jf.intel.com>
To: "Vick, Matthew" <matthew.vick@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <D0DEA929.671EB%matthew.vick@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 1/16/2015 1:41 PM, Vick, Matthew wrote:
> On 1/16/15, 10:59 AM, "Xander Huff" <xander.huff@ni.com> wrote:
>
>> From: Jeff Westfahl <jeff.westfahl@ni.com>
>>
>> The TXPBSIZE register of the i210 resets to its default value only
>> at power-on. It doesn't reset if you reboot the system, only if you
>> pull power. If something (another driver, another OS, etc.) modifies
>> this register from its default value, the igb driver doesn't function
>> correctly. It detects a hang of the transmitter and continuously resets
>> the adapter. Here we set this value to its default when resetting the
>> i210 to resolve this issue.
>
> This should have already been resolved last May in commit
> 27dff8b2f680ce966b5d959be9d69dd0edd92e3b ("igb: add defaults for i210
> TX/RX PBSIZE"). Are you running the latest upstream kernel?
>
> Cheers,
> Matthew
>
Looks like you're correct. Please disregard this patch.

-- 
Xander Huff
Staff Software Engineer
National Instruments

------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
