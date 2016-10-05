From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Wed, 05 Oct 2016 15:28:51 -0700
Message-ID: <1475706531.1941.4.camel@perches.com>
References: <20161003085640.GA8130@amd>
         <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
         <1475689996.6105.11.camel@perches.com> <20161005191103.GA25972@amd>
         <1475694934.1941.1.camel@perches.com> <20161005221317.GA21551@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0186.hostedemail.com ([216.40.44.186]:51119 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934589AbcJEW24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 18:28:56 -0400
In-Reply-To: <20161005221317.GA21551@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-06 at 00:13 +0200, Pavel Machek wrote:
> On Wed 2016-10-05 12:15:34, Joe Perches wrote:
> > On Wed, 2016-10-05 at 21:11 +0200, Pavel Machek wrote:
> > > On Wed 2016-10-05 10:53:16, Joe Perches wrote:
[]
> > > > trivia:
> > > > It's generally faster to use bool instead of u8 foo:1;
> > > Ok, but I'm not changing that in this patch.
> > > (And actually, bool will take a lot more memory, right?)
> > No worries, and bool is the same size as u8.
> Exactly what I'm talking about :-). One byte vs. one bit, right?

Memory isn't bit addressable.
So it's the same byte, it just doesn't use a read/modify/write
operation to update a value.
