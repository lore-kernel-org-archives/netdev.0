From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 0/2] Extract IFE logic to module
Date: Thu, 2 Feb 2017 11:16:43 +0100
Message-ID: <20170202101641.GA18828@penelope.horms.nl>
References: <1485871024-41836-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, davem@davemloft.net, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com, idosch@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:37981 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdBBKQr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:16:47 -0500
Received: by mail-wm0-f41.google.com with SMTP id r141so81787545wmg.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:16:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1485871024-41836-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yotam,

On Tue, Jan 31, 2017 at 03:57:02PM +0200, Yotam Gigi wrote:
> Extract ife logic from the tc_ife action into an independent module, and
> make the tc_ife action use it. This way, the ife encapsulation can be used
> by other modules other than tc_ife action.

I have no objection to this modularisation but I am curious to know
if you have a use-case in mind. My understanding is that earlier versions
of the sample action used IFE but that is not the case in the version that
was ultimately accepted.
