From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [Xen-devel] [PATCH v2] xen-apic: Enable on domU as well
Date: Fri, 7 Aug 2015 16:37:49 +0200
Message-ID: <CAHmME9qbFqq6TmXsBbmcY0yPqT5ccxbtY5-PFZowJ1D8a+9t4A@mail.gmail.com>
References: <1438878579-26856-1-git-send-email-Jason@zx2c4.com>
	<1438879025-27362-1-git-send-email-Jason@zx2c4.com>
	<20150807142329.GC29527@l.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, xen-devel@lists.xen.org,
	stable@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:60060 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932072AbbHGOh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Aug 2015 10:37:57 -0400
In-Reply-To: <20150807142329.GC29527@l.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 7, 2015 at 4:23 PM, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> Anyhow, your patch seems to fix a regression my patch
> feb44f1f7a4ac299d1ab1c3606860e70b9b89d69
> "x86/xen: Provide a "Xen PV" APIC driver to support >255 VCPUs"
> introduced.

Ahhh, good, okay. That explains why I didn't encounter this with older
kernels. The whole picture makes sense now. Thanks for reviewing this.

David - mergable?
