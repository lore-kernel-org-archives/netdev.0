From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] sotftmac: fix a slab corruption in WEP restricted key
	association
Date: Fri, 13 Oct 2006 11:04:51 +0200
Message-ID: <1160730291.2697.10.camel@ux156>
References: <452D6D80.3020005@free.fr>  <452D8D83.60908@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Laurent Riffard <laurent.riffard@free.fr>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:4227 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750943AbWJMJEI
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 05:04:08 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <452D8D83.60908@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-10-11 at 20:34 -0400, Daniel Drake wrote:

> > -        is_shared_response ? 0 : 1 + 1 + net->challenge_len
> > +        (is_shared_response ? 1 + 1 + net->challenge_len : 0)

Good catch. We should send this to -stable too I think. Mind reposting
the patch in an applicable format to Daniel, netdev, john, -stable (and
possibly me)? Quoted isn't too useful :)

Oh and you can add

Acked-by: Johannes Berg <johannes@sipsolutions.net>

johannes
