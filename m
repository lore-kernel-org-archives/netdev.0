From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Tue, 2 Jun 2015 09:13:05 -0400
Message-ID: <20150602131303.GA588@gospo.home.greyhouse.net>
References: <1433132704-21927-1-git-send-email-simon.horman@netronome.com>
 <20150601.160556.2300618386117820098.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.horman@netronome.com, sfeldma@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34407 "EHLO
	mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758946AbbFBNNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 09:13:12 -0400
Received: by qkoo18 with SMTP id o18so100387488qko.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 06:13:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150601.160556.2300618386117820098.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 01, 2015 at 04:05:56PM -0700, David Miller wrote:
> From: Simon Horman <simon.horman@netronome.com>
> Date: Mon,  1 Jun 2015 13:25:04 +0900
> 
> > The rocker (switch) of a rocker_port may be trivially obtained from
> > the latter it seems cleaner not to pass the former to a function when
> > the latter is being passed anyway.
> > 
> > rocker_port_rx_proc() is omitted from this change as it is a hot path case.
> > 
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> > Acked-by: Scott Feldman <sfeldma@gmail.com>
> 
> Applied, thanks Simon.
> 
> Andy, DO NOT quote an entire patch just to ACK it.
> 
> That is, unless you think my time is better spend scrolling over and
> over across multiple copies of the same patch in the patchwork page
> while I review a change than it is spent actually reviewing people's
> work.

Will do.  Sorry for the noise and added work.
