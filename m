From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Wed, 17 Sep 2003 08:42:17 +0200
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <200309170842.17766.bdschuym@pandora.be>
References: <200309022116.41697.bdschuym@pandora.be> <200309161757.50682.bdschuym@pandora.be> <20030916182335.359c419f.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: tommy@home.tig-grr.com, laforge@netfilter.org,
	acme@conectiva.com.br, netfilter-devel@lists.netfilter.org,
	netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030916182335.359c419f.davem@redhat.com>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Wednesday 17 September 2003 03:23, David S. Miller wrote:
> But recall that there are other netfilter modules doing this
> "compare chars using cast to long" trick that need to be fixed
> too.

Well, acme hasn't reported any other issues. Perhaps Rusty had foresight about 
these possible issues and made sure alignment was good...
In which case I don't see any reason for altering his code.

> Also, adding attributes to user exported structures would need
> to be done _very_ carefully, as compilation when using such
> gcc extensions will fail when the user uses '-ansi' on the
> compiler command line.

Now why on Earth would I have to bother with some luser doing this? I'm not 
the slave of annoying users.

cheers,
Bart
