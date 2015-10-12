From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 PATCH] iplink: Support VF Trust
Date: Mon, 12 Oct 2015 09:54:23 -0700
Message-ID: <20151012095423.4feabde1@urahara>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05F42A95@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34642 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbbJLQyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 12:54:11 -0400
Received: by padhy16 with SMTP id hy16so158404878pad.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 09:54:10 -0700 (PDT)
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05F42A95@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 Oct 2015 10:06:32 +0000
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

I am waiting until this is accepted into kernel before merging it into iproute2.
