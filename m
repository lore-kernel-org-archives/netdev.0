From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Sat, 28 Sep 2002 04:34:40 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020928043440.A1435@wotan.suse.de>
References: <20020927.182833.66704359.davem@redhat.com> <200209280228.GAA02633@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, yoshfuji@linux-ipv6.org,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
Content-Disposition: inline
In-Reply-To: <200209280228.GAA02633@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Sep 28, 2002 at 06:28:29AM +0400, A.N.Kuznetsov wrote:
> Hello!
> 
> > Otherwise I have no problems with the patch, Alexey?
> 
> I have... The implementation is bad. Source address must be retieved
> from route, not running this elephant function each packet.

So it just needs to be moved into ip_route_output, right ? 

-Andi
