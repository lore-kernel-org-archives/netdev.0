From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Bonding-devel] [patch] (2/8) Add 802.3ad support to bonding
 (released to bonding on sourceforge)
Date: Thu, 20 Mar 2003 19:57:00 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3E7A635C.3090000@pobox.com>
References: <OF1BD71312.6E4C42DC-ON88256CF0.000314A8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hshmulik@intel.com,
	bonding-devel@lists.sourceforge.net,
	bonding-announce@lists.sourceforge.net, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <OF1BD71312.6E4C42DC-ON88256CF0.000314A8@us.ibm.com>
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
>       Fair enough; the delay has gotten excessive of late.
> 
>       Would it be satisfactory going forward for the sourceforge site to
> contain patches to "standard" releases (e.g., 2.4.20), and do updates to
> the current development kernel and the sourceforge site simultaneously? In
> other words, sourceforge has a patch containing all bonding updates since
> 2.4.20 (or whichever version) was released, and each time that patch is
> updated, the incremental update goes out for inclusion in the development
> kernel.


The ideal situation is for you to send two sets of patches, one for 2.4 
tree and one for 2.5 tree.  Those will get applied to 2.4.21-pre and 
2.5.<latest>.  Patches against 2.4.20 proper are ok as long as they 
apply correctly to the latest 2.4.21-pre tree (so, patches against 
2.4.21-pre are preferred)

If the patches are the same for 2.4 and 2.5, just send one set and note 
that fact.  My preference would be to address these patches

	To: davem@redhat.com
	CC: netdev@oss.sgi.com, jgarzik@pobox.com

(David, feel free to correct me here, or direct patches to me)

When you receive bug fixes, forwarding ASAP would be very much appreciated.

	Jeff



