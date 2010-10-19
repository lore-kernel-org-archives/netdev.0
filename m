From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bridge: Forward reserved group addresses if !STP
Date: Mon, 18 Oct 2010 20:28:58 -0700
Message-ID: <20101018202858.7342f2cb@nehalam>
References: <20101018093837.26bb149a@nehalam>
	<1287454175-22903-1-git-send-email-benjamin.poirier@polymtl.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <benjamin.poirier@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37078 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753430Ab0JSD3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 23:29:37 -0400
In-Reply-To: <1287454175-22903-1-git-send-email-benjamin.poirier@polymtl.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Oct 2010 22:09:35 -0400
Benjamin Poirier <benjamin.poirier@polymtl.ca> wrote:

> Make all frames sent to reserved group MAC addresses (01:80:c2:00:00:00 to
> 01:80:c2:00:00:0f) be forwarded if STP is disabled. This enables
> forwarding EAPOL frames, among other things.
> 
> Signed-off-by: Benjamin Poirier <benjamin.poirier@polymtl.ca>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
