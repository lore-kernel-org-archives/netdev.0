From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] flower: check unused bits in MPLS fields
Date: Tue, 2 May 2017 13:44:49 +0200
Message-ID: <20170502114448.GA24820@vergenet.net>
References: <1493647120-17406-1-git-send-email-benjamin.lahaise@netronome.com>
 <af1de251-299e-a037-f4b1-21cb22051bf9@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin LaHaise <benjamin.lahaise@netronome.com>,
        netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>, Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:36924 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbdEBLo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 07:44:56 -0400
Received: by mail-wm0-f44.google.com with SMTP id m123so16467913wma.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 04:44:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <af1de251-299e-a037-f4b1-21cb22051bf9@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 09:37:00PM -0400, Jamal Hadi Salim wrote:
> On 17-05-01 09:58 AM, Benjamin LaHaise wrote:
> >Since several of the the netlink attributes used to configure the flower
> >classifier's MPLS TC, BOS and Label fields have additional bits which are
> >unused, check those bits to ensure that they are actually 0 as suggested
> >by Jamal.
> >
> >Signed-off-by: Benjamin LaHaise <benjamin.lahaise@netronome.com>
> >Cc: David Miller <davem@davemloft.net>
> >Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> >Cc: Simon Horman <simon.horman@netronome.com>
> >Cc: Jakub Kicinski <kubakici@wp.pl>
> >Cc: Jiri Pirko <jiri@resnulli.us>
> 
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
