From: Peter Bieringer <pb@bieringer.de>
Subject: Re: (usagi-users 02296) IPv6 duplicate address bugfix
Date: Mon, 31 Mar 2003 20:23:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <9360000.1049135038@worker.muc.bieringer.de>
References: <20030330122705.GA18283@ferrara.linux.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ds6-devel@deepspace6.net
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-users@linux-ipv6.org, netdev@oss.sgi.com
In-Reply-To: <20030330122705.GA18283@ferrara.linux.it>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

just my 2 cents, I already saw, that newest USAGI snapshot include a fix.



--On Sunday, March 30, 2003 02:27:05 PM +0200 Simone Piunno
<pioppo@ferrara.linux.it> wrote:

> When adding an IPv6 address to a given interface, I'm allowed to
> add that address multiple time, e.g.:

...

I didn't dig into any patch and also not into related drafts/RFCs, but one
scenario should be catched I think - or to be discussed:

Scenario:

Address was already added by autoconfiguration on receiving advertisement
(limited lifetime). Now the same address would be added manually (unlimited
lifetime).

What (should) happen?

Mho: manual add is allowed, both addresses need to be listed.

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
