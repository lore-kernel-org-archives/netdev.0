From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Fri, 17 Dec 2010 19:59:17 -0800
Message-ID: <20101217195917.33140980@nehalam>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>,
	Laurent Chavey <chavey@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Nandita Dukkipati <nanditad@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54899 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755708Ab0LRD7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 22:59:20 -0500
In-Reply-To: <1292642451-892-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Dec 2010 19:20:51 -0800
Nandita Dukkipati <nanditad@google.com> wrote:

> This patch changes the default initial receive window to 10 mss
> (defined constant). The default window is limited to the maximum
> of 10*1460 and 2*mss (when mss > 1460).
> 
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>

This needs way more discussion because it makes Linux non-RFC
breaking the RFC behavior should require explicit user override.
I also wonder if the magic value 10 should be a sysctl.
