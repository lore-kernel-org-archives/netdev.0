From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] mpls: Allow mpls_gso and mpls_router to be built as modules
Date: Tue, 10 Mar 2015 12:17:42 -0500
Message-ID: <87y4n4kc09.fsf@x220.int.ebiederm.org>
References: <1426005479-21806-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:42877 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106AbbCJRVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 13:21:42 -0400
In-Reply-To: <1426005479-21806-1-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Tue, 10 Mar 2015 16:37:59 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> CONFIG_MPLS=m doesn't result in a kernel module being built because it
> applies to the net/mpls directory, rather than to .o files.
>
> So revert the MPLS menuitem to being a boolean and make MPLS_GSO and
> MPLS_ROUTING tristates to allow mpls_gso and mpls_router modules to be
> produced as desired.

Good catch.  But I am pretty certain this does not result in the mpls
routing code in af_mpls being built as a module either.

Eric
