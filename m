From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Fixed NetEm's reorder option
Date: Wed, 11 Jun 2008 14:49:18 -0700
Message-ID: <20080611144918.1668e3d8@extreme>
References: <48479f6a.e203be0a.73e1.fffff59b@mx.google.com>
	<6de6b1650806111305m51bf2eccocbe0d0c7afee266d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Rafael Almeida" <almeidaraf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51923 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752372AbYFKVtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 17:49:55 -0400
In-Reply-To: <6de6b1650806111305m51bf2eccocbe0d0c7afee266d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Jun 2008 17:05:10 -0300
"Rafael Almeida" <almeidaraf@gmail.com> wrote:

> I noticed no one said anything about my patch below, did I do
> something terrible wrong? Should I just be more patient?
> 
> On Thu, Jun 5, 2008 at 1:34 AM, Rafael C. de Almeida
> <almeidaraf@gmail.com> wrote:
> > The reorder option wasn't working correctly. It would only kick in if
> > the gap option was set. In that case it would only lower the
> > probability of reordering packets because of how the if conditional
> > was stated.
> >
> > This patch separetes the algorithm for reordering with gap from the
> > rest, rendering the code more readable and correct.
> >
> > Signed-off-by: Rafael C. de Almeida <rafaelc@dcc.ufmg.br>

Haven't had time to look at this in detail, and I worry about the impact
of changing assumptions people already have in their scripts.
