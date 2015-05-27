From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v5 3/3] ixgbe: Add new ndo to trust VF
Date: Wed, 27 May 2015 18:04:27 +0100
Message-ID: <5565F91B.8080405@solarflare.com>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05EB28F4@BPXM14GP.gisp.nec.co.jp> <F6FB0E698C9B3143BDF729DF22286646912FB5E4@ORSMSX110.amr.corp.intel.com> <7F861DC0615E0C47A872E6F3C5FCDDBD05EB3B4A@BPXM14GP.gisp.nec.co.jp> <F6FB0E698C9B3143BDF729DF22286646912FBBEC@ORSMSX110.amr.corp.intel.com> <7F861DC0615E0C47A872E6F3C5FCDDBD05EB4EE6@BPXM14GP.gisp.nec.co.jp> <C5551D9AAB213A418B7FD5E4A6F30A07892F9481@ORSMSX108.amr.corp.intel.com> <F6FB0E698C9B3143BDF729DF22286646912FC2E3@ORSMSX110.amr.corp.intel.com> <7F861DC0615E0C47A872E6F3C5FCDDBD05EB8A65@BPXM14GP.gisp.nec.co.jp> <F6FB0E698C9B3143BDF729DF22286646912FDC17@ORSMSX110.amr.corp.intel.com> <C5551D9AAB213A418B7FD5E4A6F30A07892FC8C7@ORSMSX108.amr.corp.intel.com> <7F861DC0615E0C47A872E6F3C5FCDDBD05EB9DA7@BPXM14GP.gisp.nec.co.jp> <5565887B.5010808@sol
 arflare.com> <F6FB0E698C9B3143BDF729DF22286646912FE16E@ORSMSX110.amr.corp.intel.com> <C5551D9AAB213A418B7FD5E4A6F30A07892FD632@ORSMSX108.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:10622 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751474AbbE0RE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:04:57 -0400
In-Reply-To: <C5551D9AAB213A418B7FD5E4A6F30A07892FD632@ORSMSX108.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/05/15 16:55, Rose, Gregory V wrote:
> There's nothing to prevent any vendor from notifying a VF that it has privileges and there's nothing that require that they do.  This should be a vendor specific detail.
Agreed - purely a driver implementation detail.
> So now that I've stated my preference let me also state that I do not want to hold up acceptance of the Hiroshi's if_link patch that sets the trusted/privileged state for the VF while we further discuss this driver specific detail.
Agreed.
