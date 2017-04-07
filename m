From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] net: ipv6: Removed unnecessary parenthesis
Date: Fri, 7 Apr 2017 18:31:57 +0200
Message-ID: <20170407163157.GA10529@salvia>
References: <20170329090243.GA24402@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329090243.GA24402@arushi-HP-Pavilion-Notebook>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 02:32:43PM +0530, Arushi Singhal wrote:
> Removed parentheses on the right hand side of assignment, as they are
> not required. The following coccinelle script was used to fix this
> issue:
> 
> @@
> local idexpression id;
> expression e;
> @@
> 
> id =
> -(
> e
> -)

You sent me two patches for this:

http://patchwork.ozlabs.org/patch/744661/
http://patchwork.ozlabs.org/patch/744702/

The follow up one does not indicate v2, so I'm confused. I'm not sure
this is a resend or just a new version.

Another question that is not clear from your description is if you had
a look at the entire tree to find more spots like this, or you just
found this one and update it.

Ideally, it would be better to fix everything in one go, so we don't
have to deal with oneliner patches that just fix one single spot.

Thanks!
