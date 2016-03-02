From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] iplink: Support VF Trust
Date: Wed, 2 Mar 2016 09:20:17 -0800
Message-ID: <20160302092017.44982621@xeon-e3>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05FB353F@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36760 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753373AbcCBRUG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 12:20:06 -0500
Received: by mail-pf0-f181.google.com with SMTP id 63so7931085pfe.3
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 09:20:05 -0800 (PST)
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05FB353F@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Feb 2016 02:40:18 +0000
Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com> wrote:

> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> 
> Add IFLA_VF_TRUST message to trust the VF.
> PF can accept some privileged operation from the trusted VF.
> For example, ixgbe PF doesn't allow to enable VF promiscuous mode until
> the VF is trusted because it may hurt performance.
> 
> To trust VF.
>  # ip link set dev eth0 vf 1 trust on
> 
> To untrust VF.
>  # ip link set dev eth0 vf 1 trust off
> 
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

Applied.
