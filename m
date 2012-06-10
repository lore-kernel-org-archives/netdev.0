From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] ieee802154: verify packet size before trying to allocate
 it
Date: Sun, 10 Jun 2012 14:55:22 +0200
Message-ID: <4FD4993A.8040804@computer.org>
References: <1339326619-1753-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dbaryshkov@gmail.com, slapin@ossfans.org, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sasha Levin <levinsasha928@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339326619-1753-1-git-send-email-levinsasha928@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/10/2012 01:10 PM, Sasha Levin wrote:
> Currently when sending data over datagram, the send function will attempt to
> allocate any size passed on from the userspace.
> 
> We should make sure that this size is checked and limited. The maximum size
> of an IP packet seemed like the safest limit here.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

As I understand it this issue was present in the original code that was
introduced in 2.6.31 RC1. Should this therefore be submitted to stable
(in which case David will do so)?

Commit ID 9ec7671603573ede31207eb5b0b3e1aa211b2854

Thanks, Jan
