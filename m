From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/1] net sched: Added the TC_LINKLAYER_CUSTOM linklayer
 type
Date: Tue, 4 Jul 2017 17:34:50 +0200
Message-ID: <20170704153450.GB1865@nanopsycho>
References: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
 <20170704054832.GA1865@nanopsycho>
 <CAA0ESdoOd9V_=NqUtM4Nmxvb+tz+AiMAfXvS6ndNLaif59+WUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, McCabe@rockwellcollins.com
To: Robert McCabe <robert.mccabe@rockwellcollins.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:36340 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751902AbdGDPey (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 11:34:54 -0400
Received: by mail-wr0-f171.google.com with SMTP id c11so250991559wrc.3
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 08:34:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAA0ESdoOd9V_=NqUtM4Nmxvb+tz+AiMAfXvS6ndNLaif59+WUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jul 04, 2017 at 04:49:24PM CEST, robert.mccabe@rockwellcollins.com wrote:
>> You dump stab->data to user. How is this related to TC_LINKLAYER_CUSTOM
>> and howcome this "is to support user-space modification of the qdisc
>> stab" as your description says? I'm confused...
>
>I have a related patch for iproute2 where the "custom" link-layer is
>used to allow
>user modification of the qdisc stab.  Dumping stab->data to the user
>is used in the
>iproute2 patch to show the current size translation table.

Even so, the kernel patch you sent does not make any sense. Introduces
TC_LINKLAYER_CUSTOM but does not use it.
