From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net] Altera TSE: Fix sparse errors and warnings
Date: Fri, 9 May 2014 12:21:24 -0500
Message-ID: <CAOwfj2M4r+1WDa14M8hn-T_u6BYoWyFm4a-UsiU0AF2=kRPseA@mail.gmail.com>
References: <1399572940-32233-1-git-send-email-vbridgers2013@gmail.com>
	<1399572940-32233-2-git-send-email-vbridgers2013@gmail.com>
	<20140509152752.GN6455@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:45453 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757219AbaEIRVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:21:25 -0400
Received: by mail-we0-f182.google.com with SMTP id t60so4335237wes.27
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 10:21:24 -0700 (PDT)
In-Reply-To: <20140509152752.GN6455@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tobias,

On Fri, May 9, 2014 at 10:27 AM, Tobias Klauser <tklauser@distanz.ch> wrote:

>
> This doesn't seem to be related to the sparse/cppcheck cleanup.
> Shouldn't this be an own patch?

Thanks for catching this, I'll break this out in the next version.

>>
>> -struct altera_dmaops altera_dtype_sgdma = {
>> +static struct altera_dmaops altera_dtype_sgdma = {
>
> This can probably also be made const.

I'll look at this and include in the next version submission if possible.

>> -struct altera_dmaops altera_dtype_msgdma = {
>> +static struct altera_dmaops altera_dtype_msgdma = {
>
> Ditto.

Same,

>
> Cheers
> Tobias

Thanks for taking a look at this,

All the best,

Vince
