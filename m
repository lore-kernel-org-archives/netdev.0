From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: RTM_DELROUTE on interface going down - when to send?
Date: Tue, 17 Dec 2013 13:11:32 +0100
Message-ID: <CAKfDRXi86Tb6ocJ9kegfQqWDcXG8i20yxdK0UqSnQ=1WWaaOuQ@mail.gmail.com>
References: <20131217110512.GA11216@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:64928 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3LQMLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 07:11:33 -0500
Received: by mail-pb0-f43.google.com with SMTP id rq2so6848004pbb.16
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 04:11:33 -0800 (PST)
In-Reply-To: <20131217110512.GA11216@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

On Tue, Dec 17, 2013 at 12:05 PM, Michal Kubecek <mkubecek@suse.cz> wrote:
>
> Before I start with the patch, I would like to ask: would it be more
> appropriate to send the message when the route is marked as dead or when
> it is actually deleted from the trie?

I noticed the same thing a few months ago and submitted a patch
(http://www.spinics.net/lists/netdev/msg254106.html). However, it was
not applied because it would cause too much traffic on large-scale
routers (see davem's reply here
http://www.spinics.net/lists/netdev/msg254186.html).

-Kristian
