From: Jon Stanley <jstanley@rmrf.net>
Subject: Re: [patch net] vlan: allow to change type when no vlan device is
 hooked on netdev
Date: Wed, 17 Oct 2012 12:06:33 -0400
Message-ID: <CAJtaB1v-rpvi62nL+65ZP6M0siVSeidskZLSSPuuTJz96JoZxA@mail.gmail.com>
References: <1350473856-29380-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, fubar@us.ibm.com,
	andy@greyhouse.net, kaber@trash.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:47388 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755212Ab2JQQGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 12:06:34 -0400
Received: by mail-qa0-f53.google.com with SMTP id s11so605783qaa.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 09:06:33 -0700 (PDT)
In-Reply-To: <1350473856-29380-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 7:37 AM, Jiri Pirko <jiri@resnulli.us> wrote:

> vlan_info might be present but still no vlan devices might be there.
> That is in case of vlan0 automatically added.
>
> So in that case, allow to change netdev type.

Confirmed to work, thanks!
