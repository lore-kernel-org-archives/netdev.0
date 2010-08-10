From: Joe Perches <joe@perches.com>
Subject: Re: [patch 2/2] qlcnic: using too much stack
Date: Mon, 09 Aug 2010 20:39:06 -0700
Message-ID: <1281411546.1954.102.camel@Joe-Laptop.home>
References: <20100809103727.GH9031@bicker>
	 <0081C370-65E2-434F-BBC6-C688F6F39750@qlogic.com>
	 <20100809184254.GJ9031@bicker>
	 <9F31A875-3A0B-4518-8106-1012E0D2799B@qlogic.com>
	 <1281405801.1954.65.camel@Joe-Laptop.home>
	 <D084A42E-7F2A-44F7-9273-DDD9214CB877@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <error27@gmail.com>,
	Amit Salecha <amit.salecha@qlogic.com>,
	Linux Driver <Linux-Driver@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2348 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756410Ab0HJDjI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Aug 2010 23:39:08 -0400
In-Reply-To: <D084A42E-7F2A-44F7-9273-DDD9214CB877@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-08-09 at 20:31 -0700, Anirban Chakraborty wrote:
> On Aug 10, 2010, at 7:33 AM, Joe Perches wrote:
> > On Mon, 2010-08-09 at 18:43 -0700, Anirban Chakraborty wrote:
> >> Your patch is fine except that the preferred way is to use kzalloc over kaclloc. kzalloc does not need that extra
> >> argument that you are passing to kcalloc.
> > You probably meant to write "my preferred way"
> > as the kcalloc to "kzalloc with a multiply"
> > ratio is pretty high.
> I was suggesting based on the following:
> http://lwn.net/Articles/147014/

Note that article suggests kzalloc for allocating
a single zeroed object.

kcalloc is used for multiple zeroed objects and
protects against oversized allocations.


