From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] libertas: Convert lbs_pr_<level> to pr_<level>
Date: Wed, 04 May 2011 14:01:06 -0700
Message-ID: <1304542866.1788.102.camel@Joe-Laptop>
References: <cover.1304379925.git.joe@perches.com>
	 <353dfb1607172b5a3dbaccddbe52c24312d42af4.1304379925.git.joe@perches.com>
	 <1304537949.1097.8.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1246 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755822Ab1EDVBI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 May 2011 17:01:08 -0400
In-Reply-To: <1304537949.1097.8.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 14:39 -0500, Dan Williams wrote:
> On Mon, 2011-05-02 at 16:49 -0700, Joe Perches wrote:
> > Use the standard pr_<level> functions eases grep a bit.
> > Added a few missing terminating newlines to messages.
> > Coalesced long formats.
> Is there any reason to not put the pr_fmt() definition into 'defs.h'
> instead of C&P at the top of every file?  I don't really care either way
> but that seems cleaner since almost all the libertas files are going to
> use logging.

It has to be before any #include <linux/kernel.h>
or any other #include that uses it.

At some point, all of the uses of

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

should be removed as I intend to have that
or an equivalent become the default.


