From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: network-namespace and NETLINK_INET_DIAG - kernel v3.2.39-longterm
Date: Tue, 05 Mar 2013 13:01:43 -0800
Message-ID: <87boaxd0i0.fsf@xmission.com>
References: <1362507649.2840.55.camel@pro6455b.example.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: dilip.daya@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59387 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845Ab3CEVBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 16:01:53 -0500
In-Reply-To: <1362507649.2840.55.camel@pro6455b.example.com> (Dilip Daya's
	message of "Tue, 05 Mar 2013 13:20:49 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dilip Daya <dilip.daya@hp.com> writes:

> Hi Eric et al,
>
> Re: Network-namespace and NETLINK_INET_DIAG
>
> => Network namespace (kernel v3.2.39-longterm) not allowing /bin/ss
>    missing information from structs tcp_info  and  inet_diag_meminfo.
>    This is fixed in kernel v3.6-rc1. Are there identifiable patchsets
>    from kernel v3.6-rc1 that can be easily backported to
>    kernel v3.2.x-longterm ??

Possibly.  Certainly the patches that changed this were INET_DIAG
specific.  Take a look in the git history.

Not having a feature implemented is not the same as a bug.  So I don't
expect anyone is in a rush to backport this.

Eric
