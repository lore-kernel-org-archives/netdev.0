From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2] e1000e: display a warning message when SmartSpeed works
Date: Wed, 16 Jan 2013 13:59:32 +0100
Message-ID: <87sj61gu6j.fsf@nemi.mork.no>
References: <50F60F18.2030108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	e1000-devel@lists.sourceforge.net
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55605 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751969Ab3APNAE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 08:00:04 -0500
In-Reply-To: <50F60F18.2030108@jp.fujitsu.com> (Koki Sanagi's message of "Wed,
	16 Jan 2013 11:23:20 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Koki Sanagi <sanagi.koki@jp.fujitsu.com> writes:

> +			if (phy->speed_downgraded)
> +				netdev_warn(netdev, "Link Speed was "
> +					"downgraded by SmartSpeed\n");
> +

Could you please avoid breaking the string both here and in the igb
patch?  This breaks the ability to grep for the warning.

Quoting Documentation/CodingStyle, Chapter 2:
"However, never break user-visible strings such as printk messages,
 because that breaks the ability to grep for them."


Bj=C3=B8rn
