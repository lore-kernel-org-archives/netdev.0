From: Dmitry Torokhov <dtor_core@ameritech.net>
Subject: Re: Last night Linus bk - netfilter busted?
Date: Fri, 11 Mar 2005 13:56:53 -0500
Message-ID: <200503111356.53620.dtor_core@ameritech.net>
References: <200503110223.34461.dtor_core@ameritech.net> <4231A498.4020101@trash.net> <20050311105136.2a5e4ddc.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050311105136.2a5e4ddc.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 11 March 2005 13:51, David S. Miller wrote:
> On Fri, 11 Mar 2005 15:00:56 +0100
> Patrick McHardy <kaber@trash.net> wrote:
> 
> > Works fine here. You could try if reverting one of these two patches
> > helps (second one only if its a SMP box).
> > 
> > ChangeSet@1.2010, 2005-03-09 20:28:17-08:00, bdschuym@pandora.be
> >    [NETFILTER]: Reduce call chain length in netfilter (take 2)
> 
> It's this change, I know it is, because Linus sees the same problem
> on his workstation.
> 
> You wouldn't happen to be seeing this problem on a PPC box would
> you?  Since Linus's machine is a PPC machine too, that would support
> my theory that this could be a compiler issue on that platform.
> 

No, it is regular PIII laptop (preempt, UP).

> Damn, wait, Patrick, I think I know what's happening.  The iptables
> IPT_* verdicts are dependant upon the NF_* values, and they don't
> cope with Bart's changes I bet.  Can you figure out what the exact
> error would be?  This kind of issue would explain the looping inside
> of ipt_do_table(), wouldn't it?
> 

-- 
Dmitry
