From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net] netlink: don't send unknown nsid
Date: Fri, 9 Jun 2017 14:33:00 -0300
Message-ID: <20170609173300.GE2850@x240.lan>
References: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
 <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170601170246.GF2673@x240.lan>
 <75fccaea-0ebe-1a2a-27d7-ad30fd99f41d@6wind.com>
 <20170601224454.GG2673@x240.lan>
 <58321cd0-6c7f-d4d8-628f-2c124d71ef82@6wind.com>
 <20170607183746.GD2658@x240.lan>
 <057303a1-5d27-1b24-c8b0-d3cf46b14825@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21433 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751535AbdFIRdN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 13:33:13 -0400
Content-Disposition: inline
In-Reply-To: <057303a1-5d27-1b24-c8b0-d3cf46b14825@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 08, 2017 at 10:31:53AM +0200, Nicolas Dichtel wrote:
> Le 07/06/2017 à 21:14, Flavio Leitner a écrit :
> > Let's say the app is restarted, or another monitoring app is executed
> > with enough perms.  How will it identify the error condition?
> Your app wants to monitor a subset of netns. It means that you already have a
> way to identify those netns, something like a file stored somewhere
> (/var/run/netns/, /proc/<pid>/ns/net, ...). Thus, it's easy to check if those
> netns have a nsid assigned in the netns where your app will open the socket.
> 
> This option was called NETLINK_F_LISTEN_ALL_NSID, because it only enables to
> listen netns *with* a nsid assigned, nothing more. It's up to the user to ensure
> that nsid are correctly assigned.

Makes sense, thanks.
-- 
Flavio
