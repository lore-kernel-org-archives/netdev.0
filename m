From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: e100 firmware in 2.6.29-rc7?
Date: Mon, 16 Mar 2009 11:47:22 -0700 (Pacific Daylight Time)
Message-ID: <alpine.WNT.2.00.0903161143180.5116@jbrandeb-desk1.amr.corp.intel.com>
References: <49BABF1F.9080909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, NetDev <netdev@vger.kernel.org>,
	dwmw2@infradead.org, jesse.brandeburg@intel.com
To: Ben Greear <greearb@candelatech.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <49BABF1F.9080909@candelatech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Fri, 13 Mar 2009, Ben Greear wrote:
> I have selected build-firmware-into-kernel
> but it seems e100 is still unhappy in 2.6.29-rc7.
> 
> e100 0000:02:01.0: firmware: requesting e100/d102e_ucode.bin
> e100: eth4: e100_request_firmware: Failed to load firmware "e100/d102e_ucode.bin": -2

can you post anything extra about your config? arch? full dmesg? full 
.config?

There have been several other reports of this but setting 
CONFIG_FIRMWARE_IN_KERNEL=y seems to fix them in general.

also please post lspci -vvv -s 2:1.0, after failing to load.  I'm curious 
if the device might be in D3 still.

you can likely just get working by commenting out the firmware load for 
e100.  It may or may not re-enable a hardware bug depending upon the 
hardware you have.

Jesse

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
