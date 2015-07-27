From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH][kernel 2.6.32] Bond interface can't send gratuitous ARP
Date: Mon, 27 Jul 2015 07:21:44 +0200
Message-ID: <20150727052144.GB19418@1wt.eu>
References: <CAOtoAkdAArhXQCWsFq6Gk2-rZudY819HEtOJNuJzGxL5zNiEcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tadavis@lbl.gov, const-g@xpert.com, ctindel@ieee.org,
	girouard@us.ibm.com, fubar@us.ibm.com, mitch.a.williams@intel.com,
	buytenh@gnu.org, greearb@candelatech.com, netdev@vger.kernel.org,
	nick@dccinc.com, davem@redhat.com
To: ????????? <xqjcool@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wtarreau.pck.nerim.net ([62.212.114.60]:23625 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbbG0FWi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 01:22:38 -0400
Content-Disposition: inline
In-Reply-To: <CAOtoAkdAArhXQCWsFq6Gk2-rZudY819HEtOJNuJzGxL5zNiEcg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Qingjie,

On Mon, Jul 27, 2015 at 09:05:29AM +0800, ????????? wrote:
> Hi,
> 
> Bond interface worked as Active-Backup mode.
> If the bond interface was added in bridge, then it's just a port of bridge.
> It doesn' have IP address.
> When bond slave changing, the current code "bond_send_gratuitous_arp"
> didn't take effect. It couldn't send gratuitous ARP.
> So I made a patch to fix this issue.
> 
> It's my first patch for kernel.
> 
> Thanks a lot for your *understanding* for any *inconvenience* caused.

Patches may only be sent for mainline kernel. Since you're trying to fix
2.6.32, you first need to check if a more recent version works properly.
If it's the case, then instead you should ask for a backport of the patch
that did the related change (it's easier for tracking bug fixes and
regressions). If the problem is also present in mainline, then you should
propose your patch for mainline. Since it's a fix, it will be backported.

BTW, please keep in mind that 2.6.32 is reaching EOL in a few months, so
it would be a good time to try newer ones (3.2 or 3.4 are rock solid now).

Hoping this helps,
Willy
