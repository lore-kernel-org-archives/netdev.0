From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [net-next PATCH] e1000: Fix for e1000 kills IPMI on a tagged
 vlan.
Date: Tue, 1 Sep 2009 02:53:29 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0909010247460.5651@bizon.gios.gov.pl>
References: <20090901001250.31418.88709.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-1050253287-1251766409=:5651"
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Dave Graham <david.graham@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:41925 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751482AbZIABNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 21:13:53 -0400
In-Reply-To: <20090901001250.31418.88709.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-1050253287-1251766409=:5651
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT



On Mon, 31 Aug 2009, Jeff Kirsher wrote:

> From: Graham, David <david.graham@intel.com>

<CUT>
> A complete solution to this issue would require further driver changes.
> The driver would need to discover if (and which) management VLANs are
> active before enabling VLAN filtering, so that it could ensure that the
> managed VLANs are included in the VLAN filter table. This discovery
> requires that the BMC identifies its VLAN in registers accessible
> to the driver, and at least on Dell PE2850 systems the BMC does not
> identify its VLAN to allow such discovery. Intel is pursuing this issue
> with the BMC vendor.
>
> Signed-off-by: Dave Graham <david.graham@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>

Thank you for both pushing this fix into the mainline and trying to 
convince Dell to fix the BMC code.

BTW: this problem also exists on Dell 1425SC and probably on all 
e1000-based Dell servers.

Best regards,


 				Krzysztof Olêdzki
---1144830174-1050253287-1251766409=:5651--
