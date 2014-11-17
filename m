From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [PATCHv2 net 0/4] Implement ndo_gso_check() for vxlan nics
Date: Mon, 17 Nov 2014 09:50:04 -0800
Message-ID: <201411170950.04833.joestringer@nicira.com>
References: <1415925495-59312-1-git-send-email-joestringer@nicira.com> <20141114.171321.696698672872443302.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	shahed.shaikh@qlogic.com, amirv@mellanox.com,
	Dept-GELinuxNICDev@qlogic.com, therbert@google.com,
	gerlitz.or@gmail.com, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141114.171321.696698672872443302.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, November 14, 2014 14:13:21 David Miller wrote:
> From: Joe Stringer <joestringer@nicira.com>
> Date: Thu, 13 Nov 2014 16:38:11 -0800
> 
> > Most NICs that report NETIF_F_GSO_UDP_TUNNEL support VXLAN, and not other
> > UDP-based encapsulation protocols where the format and size of the header
> > may differ. This patch series implements a generic ndo_gso_check() for
> > detecting VXLAN, then reuses it for these NICs.
> > 
> > Implementation shamelessly stolen from Tom Herbert (with minor fixups):
> > http://thread.gmane.org/gmane.linux.network/332428/focus=333111
> > 
> > v2: Drop i40e/fm10k patches (code diverged; handling separately).
> > 
> >     Refactor common code into vxlan_gso_check() helper.
> >     Minor style fixes.
> 
> Series applied, thanks Joe.

Thanks.
