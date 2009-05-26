From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cls_cgroup: read classid atomically in classifier
Date: Tue, 26 May 2009 14:04:08 -0700
Message-ID: <20090526140408.6c829124.akpm@linux-foundation.org>
References: <20090526195840.8464.36548.stgit@menage.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lizf@cn.fujitsu.com, davem@davemloft.net, tgraf@suug.ch,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Menage <menage@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45745 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752357AbZEZVEZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 17:04:25 -0400
In-Reply-To: <20090526195840.8464.36548.stgit@menage.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 May 2009 12:59:11 -0700
Paul Menage <menage@google.com> wrote:

> Avoid reading the unsynchronized value cs->classid multiple times,
> since it could change concurrently from non-zero to zero; this would
> result in the classifier returning a positive result with a bogus
> (zero) classid.

When this race occurs, what are the user-visible consequences?

People who need to decide to which kernels a patch should be applied
like to know such things.
