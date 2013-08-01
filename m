From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 0/8] include/net: next set of extern removals
Date: Thu, 01 Aug 2013 09:29:20 -0700
Message-ID: <1375374560.2034.52.camel@joe-AO722>
References: <cover.1375316912.git.joe@perches.com>
	 <24958.1375358650@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-afs@lists.infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <24958.1375358650@warthog.procyon.org.uk>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-08-01 at 13:04 +0100, David Howells wrote:
> Joe Perches <joe@perches.com> wrote:
> > Standardize on no extern use on function prototypes
> Can we please standardise on _having_ externs on function prototypes?

Why?

What value is there in using extern for function prototypes?

Your argument for "picking out at a glance"
https://lkml.org/lkml/2013/8/1/237
really doesn't make sense to me.

Basically, anything with parentheses that's not a #define
is an extern.

Exceptions exist for extern function pointers, but those
are fairly unusual anyway.  Outside of netfilter,
extern function pointers are only used about a dozen times
total in the kernel tree.

So, please provide some examples supporting your view.


