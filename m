From: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] net/sunrpc/auth_gss/gss_krb5_crypto.c: Use normal
 negative error value return
Date: Tue, 14 Dec 2010 16:34:25 -0500
Message-ID: <1292362465.14641.10.camel@heimdal.trondhjem.org>
References: <1289786891.16461.102.camel@Joe-Laptop>
	 <20101214211922.GJ24828@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20101214211922.GJ24828-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2010-12-14 at 16:19 -0500, J. Bruce Fields wrote:
> On Sun, Nov 14, 2010 at 06:08:11PM -0800, Joe Perches wrote:
> > And remove unnecessary double semicolon too.
> > 
> > No effect to code, as test is != 0.
> 
> Hm, the error return's actually ignored.  But OK.  Applying to my tree
> for 2.6.38 assuming nobody else has picked it up.

There are also gems such as

u32 ret = -EINVAL;

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
www.netapp.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
