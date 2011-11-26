From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] utils: add s32 parser
Date: Fri, 25 Nov 2011 16:50:08 -0800
Message-ID: <20111125165008.05f4dbf3@nehalam.linuxnetplumber.net>
References: <20111125174751.GA3751@hell>
	<1322262026-8561-1-git-send-email-hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Laight@ACULAB.COM
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48207 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754035Ab1KZAuM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:50:12 -0500
In-Reply-To: <1322262026-8561-1-git-send-email-hagen@jauu.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Nov 2011 00:00:26 +0100
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> Not sure if we should save errno and restore afterwards:
> 
> errno_save = errno;
> errno = 0;
> [...]
> errno = errno_save;

Not worth it. errno is only meaningful after a failed library or syscall.
