From: Matt Porter <mporter@kernel.crashing.org>
Subject: Re: TCP IP Offloading Interface
Date: Tue, 15 Jul 2003 19:37:58 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030715193758.C8616@home.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com> <20030713004818.4f1895be.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Shih <alan@storlinksemi.com>, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030713004818.4f1895be.davem@redhat.com>; from davem@redhat.com on Sun, Jul 13, 2003 at 12:48:18AM -0700
List-Id: netdev.vger.kernel.org

On Sun, Jul 13, 2003 at 12:48:18AM -0700, David S. Miller wrote:
> On receive side, clever RX buffer flipping tricks are the way
> to go and require no protocol changes and nothing gross like
> TOE or weird buffer ownership protocols like RDMA requires.
> 
> I've made postings showing how such a scheme can work using a limited
> flow cache on the networking card.  I don't have a reference handy,
> but I suppose someone else does.

The following reference should be useful for those following along
at home and wondering what the hell this hardware flow cache scheme
is:

http://www.ussg.iu.edu/hypermail/linux/kernel/0306.2/0429.html

Regards,
-- 
Matt Porter
mporter@kernel.crashing.org
