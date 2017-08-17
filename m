From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [iproute PATCH v2 1/7] devlink: No need for this self-assignment
Date: Thu, 17 Aug 2017 21:48:50 +0200
Message-ID: <20170817194850.GA24011@nanopsycho.orion>
References: <20170817170931.24089-1-phil@nwl.cc>
 <20170817170931.24089-2-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:37119 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753212AbdHQTsx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 15:48:53 -0400
Received: by mail-wr0-f179.google.com with SMTP id z91so44091012wrc.4
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 12:48:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170817170931.24089-2-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 17, 2017 at 07:09:25PM CEST, phil@nwl.cc wrote:
>dl_argv_handle_both() will either assign to handle_bit or error out in
>which case the variable is not used by the caller.

I'm pretty sure that I did this to silence the compiler. If the compiler
bug is fixed now, good.

Acked-by: Jiri Pirko <jiri@mellanox.com>
