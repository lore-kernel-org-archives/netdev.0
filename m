From: Jeff Garzik <jeff@garzik.org>
Subject: Re: 2.6.22: ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!
Date: Wed, 27 Jun 2007 02:33:41 -0400
Message-ID: <468204C5.40104@garzik.org>
References: <20070619190253.GA19419@aepfle.de> <20070619131021.1c814098@localhost.localdomain> <20070619204110.GA21384@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Olaf Hering <olaf@aepfle.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37851 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761000AbXF0Gdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 02:33:46 -0400
In-Reply-To: <20070619204110.GA21384@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olaf Hering wrote:
> On Tue, Jun 19, Stephen Hemminger wrote:
> 
>> On Tue, 19 Jun 2007 21:02:53 +0200
>> Olaf Hering <olaf@aepfle.de> wrote:
>>
>>> What happend to __ucmpdi2 from David Woodhouse?
>>> google has a few hits about stuff like this on 32bit powerpc with gcc 4.1.2:
>>>
>>> ERROR: "__ucmpdi2" [drivers/net/s2io.ko] undefined!
>>>
>>> using the drivers/net/s2io* files from 2.6.21 with 2.6.22-rc5 fixes the
>>> compile.
>>>
>>> 25805dcf9d83098cf5492117ad2669cd14cc9b24 adds two u64 >>= 48 followed by
>>> a switch statement (line 2889 and 6816).
>> Probably the "switch(err) {" needs a cast to a smaller type (like u8).
> 
> This change removes the calls to __ucmpdi2.
> 
> ---
>  drivers/net/s2io.c |   16 +++++++++-------
>  1 file changed, 9 insertions(+), 7 deletions(-)

applied to #upstream-fixes


