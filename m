From: Andre Tomt <andre@tomt.net>
Subject: Re: PROBLEM: 2.6.11-rc2 hangs on bridge shutdown (br0)
Date: Sat, 05 Feb 2005 12:14:04 +0100
Message-ID: <4204AA7C.9010509@tomt.net>
References: <20050131162201.GA1000@stilzchen.informatik.tu-chemnitz.de> <20050205052407.GA17266@gondor.apana.org.au> <20050204213813.4bd642ad.davem@davemloft.net> <20050205061110.GA18275@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        mirko.parthey@informatik.tu-chemnitz.de, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, shemminger@osdl.org
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050205061110.GA18275@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Feb 04, 2005 at 09:38:13PM -0800, David S. Miller wrote:
> 
>>It is just the first such thing I found, scanning rt6i_idev uses
>>will easily find several others.
> 
> 
> You're right of course.  I thought they were all harmless but I was
> obviously wrong about this one.
> 
> So here is a patch that essentially reverts the split devices
> semantics introduced by these two changesets:
<..>

This patch fixes my problems with hangs when dot1q VLAN interfaces gets 
removed when loopback is down, as reported in the thread "2.6.10 
ipv6/8021q lockup on vconfig on interface removal".

Yay :)
