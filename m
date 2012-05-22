From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [IPROUTE2 2/2] tc-netem: Add support for ECN packet marking
Date: Tue, 22 May 2012 14:12:34 -0700
Message-ID: <20120522141234.36c6c6b9@nehalam.linuxnetplumber.net>
References: <1337212318-2100-1-git-send-email-subramanian.vijay@gmail.com>
	<1337212318-2100-3-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48218 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752494Ab2EVVMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 17:12:38 -0400
In-Reply-To: <1337212318-2100-3-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 May 2012 16:51:58 -0700
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> This patch provides support for marking packets with ECN instead of
> dropping them with netem. This makes it possible to make use of the
> netem ECN marking feature that was added recently to the kernel.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  include/linux/pkt_sched.h |    1 +
>  tc/q_netem.c              |   26 ++++++++++++++++++++++++++
>  2 files changed, 27 insertions(+), 0 deletions(-)
> 

Applied.

Note: I update kernel headers first (before applying changes), then
prune off the header changes from the patches. This is to make sure
that sanitized kernel headers are correct.
