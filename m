From: Robert McCabe <robert.mccabe@rockwellcollins.com>
Subject: Re: [PATCH 1/1] net sched: Added the TC_LINKLAYER_CUSTOM linklayer type
Date: Tue, 4 Jul 2017 09:49:24 -0500
Message-ID: <CAA0ESdoOd9V_=NqUtM4Nmxvb+tz+AiMAfXvS6ndNLaif59+WUg@mail.gmail.com>
References: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com> <20170704054832.GA1865@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, McCabe@rockwellcollins.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from da1vs02.rockwellcollins.com ([205.175.227.29]:53258 "EHLO
        da1vs02.rockwellcollins.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751902AbdGDOt0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 10:49:26 -0400
Received: by mail-yb0-f198.google.com with SMTP id p123so50509143ybg.10
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 07:49:26 -0700 (PDT)
In-Reply-To: <20170704054832.GA1865@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You dump stab->data to user. How is this related to TC_LINKLAYER_CUSTOM
> and howcome this "is to support user-space modification of the qdisc
> stab" as your description says? I'm confused...

I have a related patch for iproute2 where the "custom" link-layer is
used to allow
user modification of the qdisc stab.  Dumping stab->data to the user
is used in the
iproute2 patch to show the current size translation table.
