From: Aaron Brown <aaron.f.brown@intel.com>
Subject: Re: [PATCH net-next] igb: enable VLAN stripping for
	VMs with i350
Date: Fri, 07 Feb 2014 21:29:39 -0800
Message-ID: <1391837379.1875.8.camel@localhost>
References: <1386754354-22039-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	davem@davemloft.net
To: Stefan Assmann <sassmann@kpanic.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1386754354-22039-1-git-send-email-sassmann@kpanic.de>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 2013-12-11 at 10:32 +0100, Stefan Assmann wrote:
> For i350 VLAN stripping for VMs is not enabled in the VMOLR register
> but in
> the DVMOLR register. Making the changes accordingly. It's not
> necessary to
> unset the E1000_VMOLR_STRVLAN bit on i350 as the hardware will simply
> ignore
> it.
> 
> Without this change if a VLAN is configured for a VF assigned to a
> guest
> via (i.e.)
> ip link set p1p1 vf 0 vlan 10
> the VLAN tag will not be stripped from packets going into the VM.
> Which they
> should be because the VM itself is not aware of the VLAN at all.
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>

> ---
>  drivers/net/ethernet/intel/igb/e1000_82575.h | 4 ++++
>  drivers/net/ethernet/intel/igb/e1000_regs.h  | 1 +
>  drivers/net/ethernet/intel/igb/igb_main.c    | 7 +++++++
>  3 files changed, 12 insertions(+)



------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121051231&iu=/4140/ostg.clktrk
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
