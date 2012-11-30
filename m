From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH] Smack: Add missing depends on INET in Kconfig
Date: Fri, 30 Nov 2012 13:43:49 -0500
Message-ID: <8363749.LmN8tGshhp@sifl>
References: <20121129174057.99da02b15426c76054d05592@canb.auug.org.au> <50B8ECB3.2090801@schaufler-ca.com> <50B8EF79.4080907@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-security-module@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>,
	Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <50B8EF79.4080907@xenotime.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, November 30, 2012 09:40:09 AM Randy Dunlap wrote:
> On 11/30/2012 09:28 AM, Casey Schaufler wrote:
> > Because NETLABEL depends on INET SECURITY_SMACK
> > has to explicitly call out the dependency.
> > 
> > Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>
> 
> Thanks for the quick fix.

+1

Thanks Casey.

> > ---
> > 
> >  security/smack/Kconfig |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/security/smack/Kconfig b/security/smack/Kconfig
> > index 9fb14ef..1be1088 100644
> > --- a/security/smack/Kconfig
> > +++ b/security/smack/Kconfig
> > @@ -1,5 +1,6 @@
> > 
> >  config SECURITY_SMACK
> >  
> >  	bool "Simplified Mandatory Access Control Kernel Support"
> > 
> > +	depends on INET
> > 
> >  	depends on NET
> >  	depends on SECURITY
> >  	select NETLABEL
> > 
> > --
-- 
paul moore
www.paul-moore.com
