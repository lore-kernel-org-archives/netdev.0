From: "David S. Miller" <davem@redhat.com>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 23:56:50 -0700
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030916235650.0844021b.davem@redhat.com>
References: <200309022116.41697.bdschuym@pandora.be>
	<200309161757.50682.bdschuym@pandora.be>
	<20030916182335.359c419f.davem@redhat.com>
	<200309170842.17766.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tommy@home.tig-grr.com, laforge@netfilter.org, acme@conectiva.com.br,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200309170842.17766.bdschuym@pandora.be>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Wed, 17 Sep 2003 08:42:17 +0200
Bart De Schuymer <bdschuym@pandora.be> wrote:

> > Also, adding attributes to user exported structures would need
> > to be done _very_ carefully, as compilation when using such
> > gcc extensions will fail when the user uses '-ansi' on the
> > compiler command line.
> 
> Now why on Earth would I have to bother with some luser doing this? I'm not 
> the slave of annoying users.

Because you can make his life simpler merely by adding the right
__extension__() around the attribute designation, just like glibc
does in it's headers.  It takes nearly no effort on your part and
makes life simpler for everyone writing userspace programs.
