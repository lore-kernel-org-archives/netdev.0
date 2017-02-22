From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [patch net-next RFC 2/2] flow_dissecror: Move MPLS dissection
 into a separate function
Date: Wed, 22 Feb 2017 09:34:36 +0100
Message-ID: <20170222083435.GB7517@penelope.horms.nl>
References: <20170221143141.GD2694@nanopsycho.mtl.com>
 <1487687599-5464-1-git-send-email-jiri@resnulli.us>
 <1487687599-5464-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, tom@herbertland.com,
        eric.dumazet@gmail.com, dinan.gunawardena@netronome.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:35013 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754144AbdBVIel (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 03:34:41 -0500
Received: by mail-wr0-f172.google.com with SMTP id s27so3001103wrb.2
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 00:34:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1487687599-5464-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 03:33:19PM +0100, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Make the main flow_dissect function a bit smaller and move the MPLS
> dissection into a separate function. Along with that, do the MPLS header
> processing only in case the flow dissection user requires it.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
