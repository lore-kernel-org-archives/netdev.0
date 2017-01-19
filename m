From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [Xen-devel] xennet_start_xmit assumptions
Date: Thu, 19 Jan 2017 17:41:23 -0500
Message-ID: <20170119224123.GB19618@oracle.com>
References: <20170118192528.GA6847@char.us.oracle.com>
 <de0d7a7db4c24b46838aee7623d5d2a3@AMSPEX02CL03.citrite.net>
 <20170119111426.GA22018@oracle.com>
 <20170119.113759.555556955190770932.davem@davemloft.net>
 <20170119184733.GJ22018@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul.Durrant@citrix.com, konrad.wilk@oracle.com,
        wei.liu2@citrix.com, netdev@vger.kernel.org,
        xen-devel@lists.xenproject.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24563 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753724AbdASWlh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:41:37 -0500
Content-Disposition: inline
In-Reply-To: <20170119184733.GJ22018@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/19/17 13:47), Sowmini Varadhan wrote:
> > Specifically I'm talking about the dev_validate_header() check.
> > That is supposed to protect us from these kinds of situations.
> 
> ah, but I run my pf_packet application as root, so I have 
> capable(CAP_SYS_RAWIO), so I slip through the dev_validate_header()
> check.

and in that light, should dev_validate_header()
always return false if len == 0?

that will take care of all the send paths in af_packet.c
but it impacts all drivers as well (even though it is the
logically correct thing to do..)

--Sowmini
