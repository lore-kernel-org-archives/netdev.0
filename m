From: Horst von Brand <vonbrand@inf.utfsm.cl>
Subject: Re: [Coverity] Untrusted user data in kernel
Date: Fri, 17 Dec 2004 22:42:04 -0300
Message-ID: <200412180142.iBI1g5Gd007361@laptop11.inf.utfsm.cl>
References: <linux-os@chaos.analogic.com>
Cc: Bill Davidsen <davidsen@tmr.com>, James Morris <jmorris@redhat.com>,
        Patrick McHardy <kaber@trash.net>, Bryan Fulton <bryan@coverity.com>,
        netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-os@analogic.com
In-Reply-To: Message from linux-os <linux-os@chaos.analogic.com>
   of "Fri, 17 Dec 2004 11:11:37 CDT." <Pine.LNX.4.61.0412171108340.4216@chaos.analogic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

linux-os <linux-os@chaos.analogic.com> said:
> On Fri, 17 Dec 2004, Bill Davidsen wrote:

[...]

> > Are you saying that processes with capability don't make mistakes? This
> > isn't a bug related to untrusted users doing privileged operations,
> > it's a case of using unchecked user data.

> But isn't there always the possibility of "unchecked user data"?

Yes. But it should be kept to a minimum.

> I can, as root, do `cp /dev/zero /dev/mem` and have the most
> spectacular crask you've evet seen. I can even make my file-
> systems unrecoverable.

Right. And you can get rid of /dev/mem if you don't want to screw yourself
this way (which is well-known). The problem at hand is _not_ in this same
league.
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
