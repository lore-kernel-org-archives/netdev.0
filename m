From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] Smack: Add missing depends on INET in Kconfig
Date: Fri, 30 Nov 2012 09:40:09 -0800
Message-ID: <50B8EF79.4080907@xenotime.net>
References: <20121129174057.99da02b15426c76054d05592@canb.auug.org.au> <50B7F846.70202@infradead.org> <3694027.VYznNcdp7C@sifl> <2664553.2TRaVqlkGg@sifl> <50B8E4E6.2040901@xenotime.net> <50B8ECB3.2090801@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Paul Moore <paul@paul-moore.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy7-pub.bluehost.com ([67.222.55.9]:40475 "HELO
	oproxy7-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759008Ab2K3RkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 12:40:18 -0500
In-Reply-To: <50B8ECB3.2090801@schaufler-ca.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2012 09:28 AM, Casey Schaufler wrote:

> Because NETLABEL depends on INET SECURITY_SMACK
> has to explicitly call out the dependency.
> 
> Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>


Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks for the quick fix.

> ---
>  security/smack/Kconfig |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/security/smack/Kconfig b/security/smack/Kconfig
> index 9fb14ef..1be1088 100644
> --- a/security/smack/Kconfig
> +++ b/security/smack/Kconfig
> @@ -1,5 +1,6 @@
>  config SECURITY_SMACK
>  	bool "Simplified Mandatory Access Control Kernel Support"
> +	depends on INET
>  	depends on NET
>  	depends on SECURITY
>  	select NETLABEL
> 
> --


-- 
~Randy
