From: Julien Fortin <julien@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 json v2 00/27] ip: add -json support to 'ip link show'
Date: Wed, 23 Aug 2017 15:03:36 -0700
Message-ID: <CAM_1_KwMtM3A=rBmiBGJAvbpvFG409VpRj27UYOoRWEF+zEv0A@mail.gmail.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com> <20170823215126.GC22713@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:32772 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbdHWWD5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 18:03:57 -0400
Received: by mail-vk0-f48.google.com with SMTP id j189so4899048vka.0
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 15:03:57 -0700 (PDT)
In-Reply-To: <20170823215126.GC22713@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 23, 2017 at 2:51 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Aug 17, 2017 at 07:35:47PM CEST, julien@cumulusnetworks.com wrote:
>>From: Julien Fortin <julien@cumulusnetworks.com>
>>
>>This patch series adds json support to 'ip [-details] link show [dev DEV]'
>>Each patch describes the json schema it adds and provides some examples.
>
> Any plans to jsonify tc as well?

Not at the moment.
The next step would be to add support to ip addr show which shares a
lot of codes with the ip link show path (but I don't know if and when
I'd be free to do it).
