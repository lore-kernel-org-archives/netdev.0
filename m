From: "Dan Nicholson" <dbn.lists@gmail.com>
Subject: Re: [patch 03/12] sundance: set carrier status on link change events
Date: Mon, 15 Sep 2008 05:56:39 -0700
Message-ID: <91705d080809150556l33b7f05bv7779594753b1c9ce@mail.gmail.com>
References: <200808202351.m7KNpxBh006024@imap1.linux-foundation.org>
	 <48CC572E.40604@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:56102 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754615AbYIOM4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 08:56:40 -0400
Received: by yx-out-2324.google.com with SMTP id 8so622102yxm.1
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2008 05:56:40 -0700 (PDT)
In-Reply-To: <48CC572E.40604@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 13, 2008 at 5:13 PM, Jeff Garzik <jeff@garzik.org> wrote:
> akpm@linux-foundation.org wrote:
>>
>> From: Dan Nicholson <dbn.lists@gmail.com>
>>
>> Check if the link is available when a changed interrupt has been received
>> and
>> set the carrier status appropriately.  The code is copied nearly verbatim
>> from
>> the dl2k module.  The link status could be used in more places in the
>> driver,
>> but this is enough to get the carrier status reported to userspace.  Fixes
>> kernel bug #7487:
>>
>>    http://bugzilla.kernel.org/show_bug.cgi?id=7487
>>
>> [akpm@linux-foundation.org: coding-style fixes]
>> Signed-off-by: Dan Nicholson <dbn.lists@gmail.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>  drivers/net/sundance.c |   95 +++++++++++++++++++++++++--------------
>>  1 file changed, 62 insertions(+), 33 deletions(-)
>
> applied

Thanks, Jeff (and Andrew for carrying this along). I was starting to
suspect that it would never get out of mm.

--
Dan
