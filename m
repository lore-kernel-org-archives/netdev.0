From: Luciano Coelho <coelho-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] include: net: Add parameter desc to fix waring when
 generating docs
Date: Fri, 5 Jul 2013 01:43:10 +0300
Message-ID: <1372977790.21065.141.camel@cumari.coelho.fi>
References: <1372975190-21117-1-git-send-email-sam.bristow@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sam Bristow <sam.bristow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1372975190-21117-1-git-send-email-sam.bristow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-07-05 at 09:59 +1200, Sam Bristow wrote:
> 'make htmldocs' was generating a warning about a missing parameter description
> for gfp.
> 
> Earlier patch was missing my signed-off-by line...
> Signed-off-by: Sam Bristow <sam.bristow-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---

You have a typo in the patch subject (it was not there in your previous
version ;).

Also, you shouldn't add explanations about the different versions of the
patch in the commit message (in you case the "Earlier patch was missing
my signed-off-by line..." text).  If you want to add this kind of
comments, add it after the "---" under the Signed-of tags.

One more thing, it's a good idea to use [PATCH v2] when you're sending a
second version of the same patch.  That can be easily done with git
format-patch (and also with git send-email) by using an argument like
this: --subject-prefix="PATCH v2"

--
Luca.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
