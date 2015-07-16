From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v7 1/3] if_link: Add control trust VF
Date: Thu, 16 Jul 2015 17:58:19 +0300
Message-ID: <CAJ3xEMig4ZBV3Uwt_EPG6W_AWrqJinGr=ziBSpCqFPpXuaUPUw@mail.gmail.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05F039BA@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
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
Received: from mail-ob0-f176.google.com ([209.85.214.176]:35529 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbbGPO6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 10:58:19 -0400
Received: by obbop1 with SMTP id op1so48357455obb.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 07:58:19 -0700 (PDT)
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05F039BA@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 1:33 PM, Hiroshi Shimamoto
<h-shimamoto@ct.jp.nec.com> wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>
> Add netlink directives and ndo entry to trust VF user.

You haven't posted cover letter stating the V7 --> V6 and V6 --> older
versions changes

Or.


> This controls the special permission of VF user.
> The administrator will dedicatedly trust VF user to use some features
> which impacts security and/or performance.
>
> The administrator never turn it on unless VF user is fully trusted.
>
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
