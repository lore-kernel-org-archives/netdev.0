From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] net: ip, diag -- Add diag interface for raw sockets
Date: Sat, 10 Sep 2016 22:31:02 +0300
Message-ID: <20160910193102.GA2001@uranus.lan>
References: <20160909182636.GC2366@uranus.lan>
 <de68cd54-849e-93d6-b291-83e8be010f9a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NETDEV <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Andrey Vagin <avagin@openvz.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <de68cd54-849e-93d6-b291-83e8be010f9a@cumulusnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 10, 2016 at 10:31:35AM -0600, David Ahern wrote:
> On 9/9/16 12:26 PM, Cyrill Gorcunov wrote:
> > In criu we are actively using diag interface to collect sockets
> > present in the system when dumping applications. And while for
> > unix, tcp, udp[lite], packet, netlink it works as expected,
> > the raw sockets do not have. Thus add it.
> > 
> > CC: David S. Miller <davem@davemloft.net>
> > CC: Eric Dumazet <eric.dumazet@gmail.com>
> > CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> > CC: James Morris <jmorris@namei.org>
> > CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> > CC: Patrick McHardy <kaber@trash.net>
> > CC: Andrey Vagin <avagin@openvz.org>
> > CC: Stephen Hemminger <stephen@networkplumber.org>
> > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> > ---
> 
> Would you mind adding the destroy capability as well? The udp version should be close to
> what is needed for raw sockets. See udp_diag_destroy and udp_abort.

Sure, will do.
