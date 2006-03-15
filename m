From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH]: e1000 endianness bugs
Date: Wed, 15 Mar 2006 15:33:43 -0800
Message-ID: <4807377b0603151533i6a693d99ycdab71fe0a21dc4c@mail.gmail.com>
References: <20060315.142628.28661597.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeff@garzik.org, cramerj@intel.com, john.ronciak@intel.com,
	"Jesse Brandeburg" <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752167AbWCOXdq@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060315.142628.28661597.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/15/06, David S. Miller <davem@davemloft.net> wrote:
>
>         return -E_NO_BIG_ENDIAN_TESTING;
>
> [E1000]: Fix 4 missed endianness conversions on RX descriptor fields.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Yep, those look like bugs to me, thanks and congratulations, you're
the first person to test our PCI Express adapters in a big endian
system (they haven't been available before, and we don't have one,
yet)

Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
