From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: filter: validate filter priority in userspace.
Date: Tue, 10 Jul 2012 15:39:58 -0700
Message-ID: <20120710153958.1025b4e2@nehalam.linuxnetplumber.net>
References: <4FFBEBA8.1050802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40434 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753625Ab2GJWkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 18:40:14 -0400
In-Reply-To: <4FFBEBA8.1050802@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jul 2012 16:45:28 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> 
> Because we use the high 16 bits of tcm_info to pass prio value to
> kernel, thus it's range would be [0, 0xffff], without validation
> in tc when user pass a lager(>65535) priority, the actual priority
> set in kernel would confuse the user.
> 
> So, add a validation to ensure prio in the range.

Applied
