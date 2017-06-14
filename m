From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] skbuff: make skb_put_zero() return void
Date: Wed, 14 Jun 2017 14:18:16 -0700
Message-ID: <1497475096.18751.76.camel@perches.com>
References: <20170614201720.21070-1-johannes@sipsolutions.net>
         <1497472613.18751.67.camel@perches.com>
         <1497472829.9377.13.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0248.hostedemail.com ([216.40.44.248]:36339 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751760AbdFNVST (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2017 17:18:19 -0400
In-Reply-To: <1497472829.9377.13.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-06-14 at 22:40 +0200, Johannes Berg wrote:
> On Wed, 2017-06-14 at 13:36 -0700, Joe Perches wrote:
> > 
> > Given you are adding a lot of these, it might be better
> > to add an exported function that duplicates most of
> > skb_put with a memset at the end.
> 
> Yeah, could be done. I'm not sure why you'd want to duplicate it rather
> than call it though? To make it about as fast?

Yeah, that and reduced stack use.

Dunno how performance sensitive these uses really are
but it seems some might be for slow cpu wireless APs in
both the rx and tx paths.
