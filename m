From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Add unix_diag.h to kernel userspace headers
Date: Sun, 22 Jan 2012 09:38:29 -0800
Message-ID: <20120122093829.1f6d8ad9@nehalam.linuxnetplumber.net>
References: <20120120124109.478f65e3@nehalam.linuxnetplumber.net>
	<4F1B0043.1000304@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41162 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab2AVRib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Jan 2012 12:38:31 -0500
In-Reply-To: <4F1B0043.1000304@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 21 Jan 2012 22:13:23 +0400
Pavel Emelyanov <xemul@parallels.com> wrote:

> On 01/21/2012 12:41 AM, Stephen Hemminger wrote:
> > The change to use provide unix domain diag information in iproute2 means that
> > an additional header file has to be added to the kbuild header export list.
> > This ensures that any changes to the header file get picked up in future merges.
> 
> It should be already there since 6a1c9522 (unix_diag: Include unix_diag.h into header-y target)

Yup, was looking at old tree.
