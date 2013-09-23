From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: iproute2 and libnl3?
Date: Mon, 23 Sep 2013 12:19:52 -0700
Message-ID: <20130923121952.47ba4d66@nehalam.linuxnetplumber.net>
References: <1902752B0C92F943AB7EA9EE13E2DEEC1272C74D80@HQ1-EXCH02.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:51689 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab3IWTUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:20:25 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so3622733pdj.29
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 12:20:25 -0700 (PDT)
In-Reply-To: <1902752B0C92F943AB7EA9EE13E2DEEC1272C74D80@HQ1-EXCH02.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Sep 2013 11:17:40 -0700
Arvid Brodin <arvid.brodin@xdin.com> wrote:

> Hi Stephen (and others),
> 
> I'm trying to move the functionality from a small user space tool I wrote for 
> listening to HSR Netlink messages into iproute2. The tool uses generic netlink 
> through libnl3. 
> 
> It seems iproute2 uses libnl-1 though:
> 
> iphsr.c:325:6: warning: 'struct nl_sock' declared inside parameter list
> iphsr.c:334:30: error: 'NL_AUTO_PORT' undeclared (first use in this function)
> iphsr.c:341:2: warning: implicit declaration of function 'nl_send_auto'
> iphsr.c:417:2: warning: implicit declaration of function 'genl_ctrl_resolve_grp'
> iphsr.c:424:2: warning: implicit declaration of function 'nl_socket_add_memberships'
> iphsr.c:455:2: warning: implicit declaration of function 'nl_socket_alloc'
> iphsr.c:463:2: warning: implicit declaration of function 'nl_socket_disable_seq_check'
> 
> Are there alternatives to the above functionality in libnl-1, or do I need to 
> implement it myself (copy them from the libnl3 code perhaps)?
> 
> 

Upstream version of iproute does not use libnl.
Any patches to use libnl are rejected. iproute2 has its own internal libnetlink  library.
