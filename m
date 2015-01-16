From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH RESEND] igb: Reset TXPBSIZE to default value
Date: Fri, 16 Jan 2015 19:41:59 +0000
Message-ID: <D0DEA929.671EB%matthew.vick@intel.com>
References: <1421434779-20586-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Linux NICS <Linux-nics@isotope.jf.intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jeff.westfahl@ni.com" <jeff.westfahl@ni.com>,
	"Fujinaka, Todd" <todd.fujinaka@intel.com>
To: Xander Huff <xander.huff@ni.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421434779-20586-1-git-send-email-xander.huff@ni.com>
Content-Language: en-US
Content-ID: <2815939F00305243919A51C2BD802613@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/16/15, 10:59 AM, "Xander Huff" <xander.huff@ni.com> wrote:

>From: Jeff Westfahl <jeff.westfahl@ni.com>
>
>The TXPBSIZE register of the i210 resets to its default value only
>at power-on. It doesn't reset if you reboot the system, only if you
>pull power. If something (another driver, another OS, etc.) modifies
>this register from its default value, the igb driver doesn't function
>correctly. It detects a hang of the transmitter and continuously resets
>the adapter. Here we set this value to its default when resetting the
>i210 to resolve this issue.

This should have already been resolved last May in commit
27dff8b2f680ce966b5d959be9d69dd0edd92e3b ("igb: add defaults for i210
TX/RX PBSIZE"). Are you running the latest upstream kernel?

Cheers,
Matthew
