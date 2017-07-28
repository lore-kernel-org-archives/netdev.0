From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC] net: make net.core.{r,w}mem_{default,max} namespaced
Date: Fri, 28 Jul 2017 16:51:23 -0400
Message-ID: <87vamcs2t0.fsf@stressinduktion.org>
References: <20170726170333.24580-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: Matteo Croce <mcroce@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37647 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752614AbdG1UvY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 16:51:24 -0400
In-Reply-To: <20170726170333.24580-1-mcroce@redhat.com> (Matteo Croce's
        message of "Wed, 26 Jul 2017 19:03:33 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matteo Croce <mcroce@redhat.com> writes:

> The following sysctl are global and can't be read or set from a netns:
>
> net.core.rmem_default
> net.core.rmem_max
> net.core.wmem_default
> net.core.wmem_max

[...]

I think a sensible addition to those sysctls would be
tcp_moderate_rcvbuf to disable autotuning.

Thanks!
