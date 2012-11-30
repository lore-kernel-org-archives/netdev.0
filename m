From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH] Smack: Add missing depends on INET in Kconfig
Date: Fri, 30 Nov 2012 17:01:55 -0500
Message-ID: <CACLa4ptazSZCpk5Ug0mZLZRS1PxZ7KnwYxEXsXFwn3zG90YzNg@mail.gmail.com>
References: <20121129174057.99da02b15426c76054d05592@canb.auug.org.au>
	<50B7F846.70202@infradead.org>
	<3694027.VYznNcdp7C@sifl>
	<2664553.2TRaVqlkGg@sifl>
	<50B8E4E6.2040901@xenotime.net>
	<50B8ECB3.2090801@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Randy Dunlap <rdunlap@xenotime.net>,
	Paul Moore <paul@paul-moore.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LSM List <linux-security-module@vger.kernel.org>
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <50B8ECB3.2090801@schaufler-ca.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do other LSMs need this too Casey?  I remember we mentioned how select
was dangerous  :-(

On Fri, Nov 30, 2012 at 12:28 PM, Casey Schaufler
<casey@schaufler-ca.com> wrote:
> Because NETLABEL depends on INET SECURITY_SMACK
> has to explicitly call out the dependency.
>
> Signed-off-by: Casey Schaufler <casey@schaufler-ca.com>
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
>         bool "Simplified Mandatory Access Control Kernel Support"
> +       depends on INET
>         depends on NET
>         depends on SECURITY
>         select NETLABEL
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
