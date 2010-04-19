From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH]Add device drivers (GbE, Packet Hub) for Topcliff
Date: Mon, 19 Apr 2010 16:37:42 +0100
Message-ID: <1271691462.2091.24.camel@achroite.uk.solarflarecom.com>
References: <000b01cadd4c$e2f94380$66f8800a@maildom.okisemi.com>
	 <20100416083508.64199657@tpl.lwn.net>
	 <002301cadfbc$ab2e1490$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jonathan Corbet <corbet@lwn.net>, netdev@vger.kernel.org,
	andrew.chih.howe.khor@intel.com, Intel OTC <joel.clark@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <002301cadfbc$ab2e1490$66f8800a@maildom.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-04-19 at 21:34 +0900, Masayuki Ohtake wrote:
> Hi jon,
> Thanks for your suggestion again.
> I joined the netdev and send my patch to "netdev <netdev@vger.kernel.org>".
> 
> --
> Hello netdev users,
> 
> I developed the device drivers for Linux kernel 2.6.33-1.
> This time, I added the following drivers
>   - GbE device
>   - Packet HUB device
> 
> The GbE and Packet Hub device drivers are related with each other.
> Because I send patch to LKML <linux-kernel@vger.kernel.org> and the netdev
> <netdev@vger.kernel.org> mailing list.
> 
> Would you check them?
> 
> The patch is uploaded to our WEB site in Sourceforge.net,
> Because the patch size was large.
[...]

Patches must be sent directly to the list for review, with few
exceptions.

The size limit for the list is 100 K.  Given that none of your source
files are this larger, you should be able to split pch_gbe.patch into 3
or more groups of source files, each within this limit.  The changes to
drivers/net/Kconfig and drivers/net/Makefile should be in the last part.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
