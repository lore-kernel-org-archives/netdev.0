From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH ethtool] ethtool.c: fix memory leaks
Date: Mon, 27 Jun 2016 11:41:10 +0200
Message-ID: <9365ac33-5c0d-9afe-bf2a-e83790f11b74@redhat.com>
References: <1458303855-4976-1-git-send-email-ivecera@redhat.com>
 <1466931551.2504.29.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bwh@kernel.org
To: Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750869AbcF0JlN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 05:41:13 -0400
In-Reply-To: <1466931551.2504.29.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.6.2016 10:59, Ben Hutchings wrote:
> On Fri, 2016-03-18 at 13:24 +0100, Ivan Vecera wrote:
>> Memory allocated at several places is not appropriately freed.
>
> Given that ethtool is not a library or a long-running application - why
> does that matter?
>
> Ben.

Because each decently written program should clean up. Sure the kernel 
will take care about it after exit but we cannot accept the fact that 
short-running applications can behave like a pig.

Ivan
