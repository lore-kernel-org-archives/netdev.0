From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 4/4] [IPROUTE2] iproute2: link_veth support bug fixes.
Date: Wed, 12 Sep 2007 18:33:21 +0400
Message-ID: <46E7F8B1.5090907@openvz.org>
References: <m14pi0cac5.fsf@ebiederm.dsl.xmission.com>	<m1zlzsavla.fsf@ebiederm.dsl.xmission.com>	<m1veagavjr.fsf_-_@ebiederm.dsl.xmission.com> <m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:58845 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967071AbXILOfy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 10:35:54 -0400
In-Reply-To: <m1r6l4avhp.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[snip]

> @@ -25,6 +26,3 @@ clean:
>  
>  LDLIBS	+= -ldl
>  LDFLAGS	+= -Wl,-export-dynamic
> -
> -%.so: %.c
> -	$(CC) $(CFLAGS) -shared $< -o $@

%) How do we get the .so file then?
