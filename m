From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch netdev-2.6 0/2] r8169: vlan hwaccel fixes
Date: Fri, 22 Oct 2004 22:28:51 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022202851.GB4216@electric-eye.fr.zoreil.com>
References: <20041022005737.GA1945@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-kernel@vger.kernel.org, jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041022005737.GA1945@tuxdriver.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

John W. Linville <linville@tuxdriver.com> :
[...]
> Patch 1:
> 
> The return value of rtl8169_tx_vlan_tag() is not being
> endian-swapped to little endian.  The hardware registers are little
> endian, even though the vlan tag value in this register (16-bits only)
> is big endian -- confusing!  Anyway, I'll be posting a follow-up patch
> to correct this.

Oops.

> Patch 2:
[nice explanation]

Any objection against me replacing the actual comment of patch #2 (i.e.
"why" instead of "how") and splitting the "if ((tp->>vlgrp = grp))" over
two lines ?

--
Ueimor
