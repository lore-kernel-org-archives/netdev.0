From: Brice Goglin <brice@myri.com>
Subject: Re: [RESEND][PATCH 2.6.28] myri10ge: Add multiqueue TX support
Date: Thu, 25 Sep 2008 22:20:17 +0200
Message-ID: <48DBF281.7030806@myri.com>
References: <48DB1056.5040206@myri.com> <48DBE180.9090508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2016 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753535AbYIYUTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 16:19:35 -0400
In-Reply-To: <48DBE180.9090508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Brice Goglin wrote:
>> Add multiqueue TX support to myri10ge.
>>     Signed-off-by: Brice Goglin <brice@myri.com>
>
> Did not apply to net-next successfully...  I dropped the two patches
> you submitted, as discussed in the thread where DaveM replied.  Maybe
> that drop is tripping us up?
>
> Let's resync based on DaveM's current net-next, ok?

Well, I am puzzled. The last patch I sent applies fine on top of DaveM's
net-next here. We're talking about master branch of 
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git,
right ?

Actually, the same patch also applies to Linus (with a bit of
offset/fuzz) since the only differences are only 3 small DCA patches. So
I don't understand how you're getting conflicts unless you have some
remants of the nacked toeplitz stuff.

Brice

