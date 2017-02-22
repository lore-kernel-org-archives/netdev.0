From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next RFC 1/2] flow_dissecror: Move ARP dissection
 into a separate function
Date: Wed, 22 Feb 2017 09:12:23 +0100
Message-ID: <20170222081221.GA7517@penelope.horms.nl>
References: <20170221143141.GD2694@nanopsycho.mtl.com>
 <1487687599-5464-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, tom@herbertland.com,
        eric.dumazet@gmail.com, dinan.gunawardena@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35824 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752842AbdBVIM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 03:12:27 -0500
Received: by mail-wm0-f47.google.com with SMTP id v186so133488059wmd.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 00:12:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1487687599-5464-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 03:33:18PM +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Make the main flow_dissect function a bit smaller and move the ARP
> dissection into a separate function. Along with that, do the ARP header
> processing only in case the flow dissection user requires it.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

This looks good to me.

Reviewed-by: Simon Horman <simon.horman@netronome.com>
