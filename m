From: Phil Blundell <philb@gnu.org>
Subject: Re: [PATCH] econet: 4 byte infoleak to the network
Date: Thu, 17 Mar 2011 11:50:01 +0000
Message-ID: <1300362601.2132.14721.camel@phil-desktop>
References: <1300362011-8653-1-git-send-email-segoon@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, security@kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>, Nelson Elhage <nelhage@ksplice.com>,
	netdev@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300362011-8653-1-git-send-email-segoon@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-03-17 at 14:40 +0300, Vasiliy Kulikov wrote:
> struct aunhdr has 4 padding bytes between 'pad' and 'handle' fields on
> x86_64.  These bytes are not initialized in the variable 'ah' before
> sending 'ah' to the network.  This leads to 4 bytes kernel stack
> infoleak.
> 
> This bug was introduced before the git epoch.
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Well spotted.  Thanks for the patch.

Acked-by: Phil Blundell <philb@gnu.org>

p.
