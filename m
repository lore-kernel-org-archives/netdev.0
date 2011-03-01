From: Vasu Dev <vasu.dev@linux.intel.com>
Subject: Re: [Open-FCoE] [PATCH] fcoe: correct checking for bonding
Date: Tue, 01 Mar 2011 10:01:34 -0800
Message-ID: <1299002494.7692.202.camel@vi2.jf.intel.com>
References: <20110228133245.GB7096@psychotron.brq.redhat.com>
	 <8433.1298913321@death> <4D6BE155.7050109@gmail.com>
	 <20110301063710.GD2855@psychotron.redhat.com>  <4D6D31BA.3000105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>,
	James.Bottomley@HansenPartnership.com, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>, devel@open-fcoe.org,
	linux-scsi@vger.kernel.org
To: Joe Eykholt <joe.eykholt@gmail.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <4D6D31BA.3000105@gmail.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-03-01 at 09:49 -0800, Joe Eykholt wrote:
> 
> Otherwise I'd add some parens or I might code this as:
> 
>         if ((netdev->priv_flags & (IFF_BONDING | IFF_MASTER)) ==
>             (IFF_BONDING | IFF_MASTER))

or also skip == in code as:-

if (netdev->priv_flags & (IFF_BONDING | IFF_MASTER)) 

Would least save few chars in source code.

Vasu

