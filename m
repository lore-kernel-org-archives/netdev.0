From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysctl: allow override of /proc/sys/net with CAP_NET_ADMIN
Date: Fri, 30 May 2008 19:29:03 -0700
Message-ID: <m1hccfcikw.fsf@frodo.ebiederm.org>
References: <200805292349.m4TNneua029348@imap1.linux-foundation.org>
	<20080530161857.25e3fbc5@extreme> <m1wslbcjy9.fsf@frodo.ebiederm.org>
	<20080530191053.34182eaf@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linuxfoundation.org, Chris Wright <chrisw@sous-sol.org>,
	stephen.hemminger@vyatta.com, adobriyan@gmail.com,
	morgan@kernel.org, xemul@openvz.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33521 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbYEaCa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 22:30:56 -0400
In-Reply-To: <20080530191053.34182eaf@extreme> (Stephen Hemminger's message of
	"Fri, 30 May 2008 19:10:53 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:
> Unnecessary, it is a property of the root, and there is only one call to
> register_sysctl_root
> in the current code, and that registers the net_sysctl_root structure.

Oh right.  I was thinking it was a property of the ctl_table_header.
My mistake.

Then this is essentially the perfect place to put it.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Eric
