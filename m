From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [net] igbvf: remove "link is Up" message when registering mcast
 address
Date: Fri, 5 Feb 2016 02:30:11 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E7BAF5@ORSMSX101.amr.corp.intel.com>
References: <1453677772-27075-1-git-send-email-jmaxwell37@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jmaxwell@redhat.com" <jmaxwell@redhat.com>,
	"vinschen@redhat.com" <vinschen@redhat.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jon Maxwell <jmaxwell37@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453677772-27075-1-git-send-email-jmaxwell37@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: netdev-owner@vger.kernel.org [netdev-owner@vger.kernel.org] on behalf of Jon Maxwell [jmaxwell37@gmail.com]
> Sent: Sunday, January 24, 2016 3:22 PM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; jmaxwell@redhat.com; vinschen@redhat.com; intel-wired-lan@lists.osuosl.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Jon Maxwell
> Subject: [net] igbvf: remove "link is Up" message when registering mcast address
> 
> A similar issue was addressed a few years ago in the following thread:
> 
> http://www.spinics.net/lists/netdev/msg245877.html
> 
> At that time there were concerns that removing this statement may cause other
> side effects. However the submitter addressed those concerns. But the dialogue
> went cold. We have a new case where a customers application is registering and
> un-registering multicast addresses every few seconds. This is leading to many
> "Link is Up" messages in the logs as a result of the
> "netif_carrier_off(netdev)" statement called by igbvf_msix_other(). Also on
> some kernels it is interfering with the bonding driver causing it to failover
> and subsequently affecting connectivity.
> 
> The Sourgeforge driver does not make this call and is therefore not affected.
> If there were any side effects I would expect that driver to also be affected.
> I have tested re-loading the igbvf driver and downing the adapter with the PF
> entity on the host where the VM has this patch. When I bring it back up again
> connectivity is restored as expected. Therefore I request that this patch gets
> submitted.
> 
> Signed-off-by: Jon Maxwell <jmaxwell37@gmail.com>
> ---
>  drivers/net/ethernet/intel/igbvf/netdev.c | 1 -
>  1 file changed, 1 deletion(-)
> 

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
