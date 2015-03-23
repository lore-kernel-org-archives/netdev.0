From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net] rocker: handle non-bridge master change
Date: Mon, 23 Mar 2015 15:53:55 +0900
Message-ID: <20150323065353.GA16565@vergenet.net>
References: <1427091201-7872-1-git-send-email-simon.horman@netronome.com>
 <20150323062309.GA2032@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36489 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269AbbCWGyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 02:54:06 -0400
Received: by padcy3 with SMTP id cy3so182254179pad.3
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 23:54:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150323062309.GA2032@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 07:23:09AM +0100, Jiri Pirko wrote:
> Mon, Mar 23, 2015 at 07:13:21AM CET, simon.horman@netronome.com wrote:
> >Master change notifications may occur other than when joining or
> >leaving a bridge, for example when being added to or removed from
> >a bond or Open vSwitch.
> >
> >Previously in those cases rocker_port_bridge_leave() was called
> >which results in a null-pointer dereference as rocker_port->bridge_dev
> >is NULL because there is no bridge device.
> >
> >This patch makes provision for doing nothing in such cases.
> >
> >Fixes: 6c7079450071f ("rocker: implement L2 bridge offloading")
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> Acked-by: Jiri Pirko <jiri@resnulli.us>

I would like to clarify that I lightly tested this patch to the
extent that I no longer see a null-pointer dereference.
