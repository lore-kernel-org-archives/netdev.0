From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCHv3 3/7] ethtool: Use the full 32 bit speed range in
 ethtool's set_settings
Date: Thu, 28 Apr 2011 17:14:09 -0400
Message-ID: <1304025249.16087.2.camel@obelisk.thedillows.org>
References: <1303954043-17440-1-git-send-email-decot@google.com>
	 <1303954043-17440-4-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303954043-17440-4-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-27 at 18:27 -0700, David Decotigny wrote:
> This makes sure the ethtool's set_settings() callback of network
> drivers don't ignore the 16 most significant bits when ethtool calls
> their set_settings().
> 
> All drivers compiled with make allyesconfig on x86_64 have been
> updated.
> 
> Tested: make allyesconfig compiles + e1000e and bnx2x work
> Signed-off-by: David Decotigny <decot@google.com>

For what it's worth, the typhoon changes are

Acked-by: David Dillow <dave@thedillows.org>
