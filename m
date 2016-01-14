From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_unix: Use kfree for addresses in unix_bind
Date: Thu, 14 Jan 2016 10:00:35 -0800
Message-ID: <1452794435.1223.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4bsw2q5.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87y4bsw2q5.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-14 at 16:22 +0000, Rainer Weikusat wrote:
> Use kfree instead of unix_release_addr when freeing newly-allocated
> unix_address structures after binding the socket failed. The second
> function does an atomic_dec_and_test in order to free the address once
> its reference count falls to zero which isn't necessary for the
> unix_bind error path as the new structure wasn't published yet. 'Using
> kfree' is also how unix_autobind handles this case.
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> ---

This looks net-next material ?

net-next tree is closed during merge window.

Not sure what you gain by optimizing error paths ...
