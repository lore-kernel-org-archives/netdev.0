From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: more findings/questions on vlans/bonds
Date: Sun, 26 Apr 2009 17:14:15 +0300
Message-ID: <49F46C37.2050001@Voltaire.com>
References: <13724.1240520690@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:53440 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755112AbZDZOOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2009 10:14:31 -0400
In-Reply-To: <13724.1240520690@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
>         So, here's a patch with a description.  This resolves the
> bonding problem for me; it might have other undesirable side effects,
> though.  It's debatable whether it's really necessary, but it does make
> the VLAN device behave more like a real network device in this case:
> 
> [PATCH] vlan: update vlan carrier state for admin up/down

Jay, I just can't apply the patch on 2.6.30-rc2 it all fails, which
is quite weird since the code (e.g net/8021q/vlan.c) hasn't gone through
many changes recently - any idea what I do wrong?

Or.

> # patch --dry-run -p 1 < /tmp/vlans_bonds.patch
> patching file net/8021q/vlan.c
> Hunk #1 FAILED at 492.
> Hunk #2 FAILED at 508.
> 2 out of 2 hunks FAILED -- saving rejects to file net/8021q/vlan.c.rej
> patching file net/8021q/vlan_dev.c
> Hunk #1 FAILED at 462.
> Hunk #2 FAILED at 472.
> Hunk #3 FAILED at 494.
> Hunk #4 FAILED at 615.
> 4 out of 4 hunks FAILED -- saving rejects to file net/8021q/vlan_dev.c.rej

