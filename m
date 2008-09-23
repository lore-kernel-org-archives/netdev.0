From: Andi Kleen <andi@firstfloor.org>
Subject: Re: clarify code intent
Date: Tue, 23 Sep 2008 02:29:05 +0200
Message-ID: <87d4ivr9gu.fsf@basil.nowhere.org>
References: <1221757668.23007.12.camel@ns-test>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:53954 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753457AbYIWA3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 20:29:08 -0400
In-Reply-To: <1221757668.23007.12.camel@ns-test> (Mathieu Lacage's message of "Thu, 18 Sep 2008 10:07:48 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mathieu Lacage <mathieu.lacage@sophia.inria.fr> writes:

> The attached patch hopefully clarifies the intent of the unix_bind
> function in net/unix/af_unix.c. That 'feature' (the ability to delegate
> the endpoint allocation to the kernel with bind by sending a
> sockaddr_un.sun_family = AF_UNIX rather than have to wait until the
> autobind is triggered by a later call to send) would be nice to document
> in the unix '7' manpage but, I have no idea where these are maintained.

They are maintained by the manpage maintainer mtk.manpages@googlemail.com

-Andi
