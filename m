From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH RFC 3/5] printk: modify printk interface for
 syslog_namespace
Date: Mon, 19 Nov 2012 06:53:34 -0800
Message-ID: <1353336814.5287.2.camel@joe-AO722>
References: <50A9EAF0.4000902@gmail.com>
	 <20121119142926.GB4453@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Rui Xiang <leo.ruixiang@gmail.com>, serge.hallyn@canonical.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "Serge E. Hallyn" <serge@hallyn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:57179 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751798Ab2KSOxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2012 09:53:34 -0500
In-Reply-To: <20121119142926.GB4453@mail.hallyn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-11-19 at 14:29 +0000, Serge E. Hallyn wrote:
> > diff --git a/drivers/base/core.c b/drivers/base/core.c

48kb of quoted text...

> > @@ -1678,7 +1674,7 @@ asmlinkage int printk(const char *fmt, ...)
> >  	}
> >  #endif
> >  	va_start(args, fmt);
> > -	r = vprintk_emit(0, -1, NULL, 0, fmt, args);
> > +	r = vprintk_emit(0, -1, NULL, 0, fmt, args, current_syslog_ns());
> 
> Current is meaningless here.  The default should be using init_syslog_ns.

For a single sentence.  Please remember to trim your replies.
