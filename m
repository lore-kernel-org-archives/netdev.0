From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [iproute PATCH v2 1/7] devlink: No need for this self-assignment
Date: Mon, 21 Aug 2017 11:02:44 +0200
Message-ID: <20170821090244.GB2625@nanopsycho.orion>
References: <20170817170931.24089-1-phil@nwl.cc>
 <20170817170931.24089-2-phil@nwl.cc>
 <20170817194850.GA24011@nanopsycho.orion>
 <20170818102024.GF10864@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36742 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751811AbdHUJCr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 05:02:47 -0400
Received: by mail-wr0-f193.google.com with SMTP id f8so11411748wrf.3
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 02:02:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170818102024.GF10864@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Aug 18, 2017 at 12:20:24PM CEST, phil@nwl.cc wrote:
>On Thu, Aug 17, 2017 at 09:48:50PM +0200, Jiri Pirko wrote:
>> Thu, Aug 17, 2017 at 07:09:25PM CEST, phil@nwl.cc wrote:
>> >dl_argv_handle_both() will either assign to handle_bit or error out in
>> >which case the variable is not used by the caller.
>> 
>> I'm pretty sure that I did this to silence the compiler. If the compiler
>> bug is fixed now, good.
>
>That might depend on the compiler you used, so maybe you just want to
>give it a try in your environment? If it still happens, we can keep this
>self-assignment of course since it shouldn't harm.

No warning with gcc 6.3.1
