From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] checkpatch: suggest using ether_addr_equal*()
Date: Sun, 19 Apr 2015 13:23:01 -0700
Message-ID: <1429474981.2947.36.camel@perches.com>
References: <1429470246-15988-1-git-send-email-mateusz.kulikowski@gmail.com>
	 <1429470246-15988-2-git-send-email-mateusz.kulikowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: apw@canonical.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429470246-15988-2-git-send-email-mateusz.kulikowski@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-04-19 at 21:04 +0200, Mateusz Kulikowski wrote:
> Check if memcmp() is used to compare ethernet addresses and suggest using
> ether_addr_equal() or ether_addr_equal_unaligned()

Hi again Mateusz.

This is OK with me.

If you ever submit that ether_addr_copy_unaligned patch,
please update the checkpatch test for ether_addr_copy too.

Joe
