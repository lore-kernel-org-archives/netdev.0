From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next v5 1/2] flow dissector: ICMP support
Date: Wed, 7 Dec 2016 13:44:52 +0100
Message-ID: <20161207124451.GA20170@penelope.horms.nl>
References: <1481112880-9801-1-git-send-email-simon.horman@netronome.com>
 <1481112880-9801-2-git-send-email-simon.horman@netronome.com>
 <20161207122629.GE1987@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f179.google.com ([209.85.210.179]:34701 "EHLO
        mail-wj0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752883AbcLGMo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:44:56 -0500
Received: by mail-wj0-f179.google.com with SMTP id tg4so104299387wjb.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 04:44:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161207122629.GE1987@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 07, 2016 at 01:26:29PM +0100, Jiri Pirko wrote:
> Wed, Dec 07, 2016 at 01:14:39PM CET, simon.horman@netronome.com wrote:
> >Allow dissection of ICMP(V6) type and code. This should only occur
> >if a packet is ICMP(V6) and the dissector has FLOW_DISSECTOR_KEY_ICMP set.
> >
> >There are currently no users of FLOW_DISSECTOR_KEY_ICMP.
> >A follow-up patch will allow FLOW_DISSECTOR_KEY_ICMP to be used by
> >the flower classifier.
> 
> 
> You are missing signedoff line.

Ooops!
