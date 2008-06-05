From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: How I can reset TCP sockets after long suspend/resume cyscle
Date: Thu, 5 Jun 2008 11:13:40 +0400
Message-ID: <20080605071339.GA11562@2ka.mipt.ru>
References: <200806011515.14103.maximlevitsky@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53618 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751882AbYFEHNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 03:13:43 -0400
Content-Disposition: inline
In-Reply-To: <200806011515.14103.maximlevitsky@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 01, 2008 at 03:15:14PM +0300, Maxim Levitsky (maximlevitsky@gmail.com) wrote:
> Is there a way to close all TCP sockets before/after suspend to ram?

You can do that with frevoke patchset (not in mainline though iirc),
which allows you to close any file descriptor, which you can find via
/proc/$pid/fd

-- 
	Evgeniy Polyakov
