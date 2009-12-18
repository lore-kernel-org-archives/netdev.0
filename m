From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Security: Add prctl(PR_{GET,SET}_NETWORK) interface.
Date: Fri, 18 Dec 2009 09:49:55 -0800
Message-ID: <20091218094955.32938765@nehalam>
References: <20091217.225856.145758950057800056.mrs@deli>
	<20091218030056.GC3047@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Seaborn <mrs@mythic-beasts.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>,
	Michael Stone <michael@laptop.org>
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35391 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932307AbZLRRuR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 12:50:17 -0500
In-Reply-To: <20091218030056.GC3047@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Dec 2009 22:00:57 -0500
Michael Stone <michael@laptop.org> wrote:

>    5. Linux today has pretty good support for controlling the creation of
>       channels involving the filesystem and involving shared daemons. It has
>       mediocre support for access control involving sysv-ipc mechanisms. It has
>       terrible support for access control involving non-local principals like
>       "the collection of people and programs receiving packets sent to
>       destination 18.0.0.1:80 from source 192.168.0.3:34661".

The policy control for this is done today on linux via the firewalling infrastructure.
It is not clear to me that moving over to the security infrastructure is an overall
gain from the security or user interface perspective.
