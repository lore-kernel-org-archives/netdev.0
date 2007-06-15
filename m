From: Keir Fraser <Keir.Fraser@cl.cam.ac.uk>
Subject: Re: [Xen-devel] [PATCH 4/4] [Net] Support accelerated network
 plugin modules
Date: Fri, 15 Jun 2007 17:31:42 +0100
Message-ID: <C2987D7E.93CF%Keir.Fraser@cl.cam.ac.uk>
References: <1181924563.4121.94.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xensource.com>,
	<herbert@gondor.apana.org.au>
To: Kieran Mansley <kmansley@solarflare.com>,
	Zhu Han <schumi.han@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta2.cl.cam.ac.uk ([128.232.0.14]:50866 "EHLO mta2.cl.cam.ac.uk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755351AbXFOQ3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 12:29:16 -0400
In-Reply-To: <1181924563.4121.94.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/6/07 17:22, "Kieran Mansley" <kmansley@solarflare.com> wrote:

> The lock protects the use_count variable.

Yes, that's one thing I noticed -- can you use atomic_t for reference counts
and hence reduce the number of times you need to lock/unlock? At least the
open-coded lock-decrement-test-maybe-free-unlock sequences could be
abstracted into a put_foo() function.

 -- Keir


