From: Simone Piunno <pioppo@ferrara.linux.it>
Subject: Re: [ds6-devel] Re: (usagi-users 02296) IPv6 duplicate address bugfix
Date: Mon, 31 Mar 2003 20:56:48 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030331185648.GA3928@ferrara.linux.it>
References: <20030330122705.GA18283@ferrara.linux.it> <9360000.1049135038@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
	ds6-devel@deepspace6.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Peter Bieringer <pb@bieringer.de>
Content-Disposition: inline
In-Reply-To: <9360000.1049135038@worker.muc.bieringer.de>
List-Id: netdev.vger.kernel.org

On Mon, Mar 31, 2003 at 08:23:58PM +0200, Peter Bieringer wrote:

> Address was already added by autoconfiguration on receiving advertisement
> (limited lifetime). Now the same address would be added manually (unlimited
> lifetime).
> 
> What (should) happen?
> 
> Mho: manual add is allowed, both addresses need to be listed.

I'd prefer this variant:

manual add is allowed and overwrites the autoconfigured address.

-- 
 Simone Piunno -- http://members.ferrara.linux.it/pioppo 
.-------  Adde parvum parvo magnus acervus erit  -------.
 Ferrara Linux Users Group - http://www.ferrara.linux.it 
 Deep Space 6, IPv6 on Linux - http://www.deepspace6.net 
 GNU Mailman, Mailing List Manager - http://www.list.org 
`-------------------------------------------------------'
