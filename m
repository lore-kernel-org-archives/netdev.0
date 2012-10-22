From: "Perla, Sathya" <Sathya.Perla@Emulex.Com>
Subject: RE: [net-next:master 28/31]
 drivers/net/ethernet/emulex/benet/be_main.c:3116 be_flash() error:
 __builtin_memcpy() 'req->params.data_buf' too small (4 vs 32768)
Date: Mon, 22 Oct 2012 05:16:04 +0000
Message-ID: <6809953e-e6b9-474d-8569-799e8468881e@CMEXHTCAS1.ad.emulex.com>
References: <20121022032027.GA14218@yliu-dev.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "fengguang.wu@intel.com" <fengguang.wu@intel.com>,
	"Vasundhara, Volam" <Vasundhara.Volam@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yuanhan Liu <yuanhan.liu@intel.com>,
	"Ratnakar, Padmanabh" <Padmanabh.Ratnakar@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:35518 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab2JVFQK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 01:16:10 -0400
In-Reply-To: <20121022032027.GA14218@yliu-dev.sh.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Yuanhan Liu
>
>Hi Padmanabh,
>
>FYI, there are new smatch warnings show up in
>
>tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
>head:   46baac38ef633b08168d27df7b02eb14578fb760
>commit: 773a2d7c55a3d63207841c824d21920bd3683460 [28/31] be2net: Fix FW
>flashing on Skyhawk-R
>
>+ drivers/net/ethernet/emulex/benet/be_main.c:3116 be_flash() error:
>__builtin_memcpy() 'req->params.data_buf' too small (4 vs 32768)
>

Padmanabh is not in today. We'll check this and send a fix asap...
Thanks!

-Sathya
