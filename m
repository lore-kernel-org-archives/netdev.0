From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH net] ppp: take reference on channels netns
Date: Wed, 23 Mar 2016 19:02:22 +0300
Message-ID: <20160323160222.GB2231@uranus.lan>
References: <4dbdfa8e264d5a635865c6e843c122daf9be4f8d.1458747209.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Baozeng Ding <sploving1@gmail.com>,
	Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:33751 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652AbcCWQCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 12:02:25 -0400
Received: by mail-lb0-f182.google.com with SMTP id oe12so13563472lbc.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 09:02:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4dbdfa8e264d5a635865c6e843c122daf9be4f8d.1458747209.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 23, 2016 at 04:38:55PM +0100, Guillaume Nault wrote:
> Let channels hold a reference on their network namespace.
> Some channel types, like ppp_async and ppp_synctty, can have their
> userspace controller running in a different namespace. Therefore they
> can't rely on them to preclude their netns from being removed from
> under them.
> 
...
> 
> Fixes: 273ec51dd7ce ("net: ppp_generic - introduce net-namespace functionality v2")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Good catch! Thanks!

Reviewed-by: Cyrill Gorcunov <gorcunov@openvz.org>
