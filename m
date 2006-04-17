From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH][RFC] softmac: suggest TX rate
Date: Mon, 17 Apr 2006 02:02:24 +0100
Message-ID: <4442E920.60603@gentoo.org>
References: <4442E13E.80507@gentoo.org> <Pine.LNX.4.58.0604170230400.32281@p15091797.pureserver.info> <Pine.LNX.4.58.0604170235020.32457@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	softmac-dev@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:25028 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750898AbWDQAtG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 20:49:06 -0400
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <Pine.LNX.4.58.0604170235020.32457@p15091797.pureserver.info>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ulrich Kunitz wrote:
> I just wanted to say, I agree with the approach, but wonder how
> transmission timeouts come into play here, which should lead to a
> decrease of the tranmission rate. 

That's a separate issue, to do with rate management, which I'm not 
tackling yet. Note that the functions in my patch can easily be extended 
to bring rate management into the equation.

Daniel
