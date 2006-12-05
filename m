From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 1/1] myri10ge: write as 2 32-byte blocks in myri10ge_submit_8rx
Date: Tue, 05 Dec 2006 16:28:22 +0100
Message-ID: <45759016.3050207@myri.com>
References: <4573F8ED.3050304@myri.com> <4573F97B.90707@myri.com> <4574B0F9.9070409@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:55657 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S968303AbWLEP2k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Dec 2006 10:28:40 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4574B0F9.9070409@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Brice Goglin wrote:
>> In the myri10ge_submit_8rx() routine, write the 64 byte request block as
>> 2 32-byte blocks so that it is handled by the hardware pio write handler
>> if write-combining is enabled.
>>
>> Signed-off-by: Brice Goglin <brice@myri.com>
>> ---
>>  drivers/net/myri10ge/myri10ge.c |    4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>
> ACK, can you resend due to patch collision in #upstream?

Ok, I wasn't aware of the annotation fixes from Al Viro. Maybe I should
add a MAINTAINER entry so that I could get CC'ed more often when changes
are done in myri10ge ?

Anyway, I will resent an updated patch as a reply to this mail soon.

Brice

