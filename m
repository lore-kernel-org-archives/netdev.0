From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: sysctls
Date: Wed, 25 Apr 2007 14:50:18 -0700
Message-ID: <20070425145018.f373cc93.akpm@linux-foundation.org>
References: <20070425122924.88391585.akpm@linux-foundation.org>
	<m1ps5sqlv4.fsf@ebiederm.dsl.xmission.com>
	<20070425195319.GA25080@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43398 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422768AbXDYVv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 17:51:28 -0400
In-Reply-To: <20070425195319.GA25080@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Apr 2007 15:53:19 -0400
Neil Horman <nhorman@tuxdriver.com> wrote:

> I did the optimistic dad sysctl, and have no strict use for numbered sysctls (I
> was just unaware of the policy).  I'll work up a patch to use
> register_sysclt_table with CTL_UNNUMBERED in the next few days.

I don't think you need to add a call to register_sysctl_table(), if that's
what you're proposing.  Just drop the changes to sysctl.h and use CTL_UNNUMBERED
in sysctl.c.
