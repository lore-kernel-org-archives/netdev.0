From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth:Fix variable assignment for switch case in the function a2mp_chan_recv_cb
Date: Tue, 18 Aug 2015 10:43:24 -0700
Message-ID: <B1F382FE-91DF-41CE-901D-06226E833FDA@holtmann.org>
References: <1439912990-15773-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Nicholas Krause <xerofoify@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439912990-15773-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Nicholas,

> This fixes the issue with not assigning the variable err to the return
> value of the call to the function a2mp_command_rej for the switch case
> A2MP_COMMAND_REJ as this function call can fail and thus callers of
> a2mp_chan_recv_cb should be signaled when this internal function call
> fails in order for them to handle this failure when calling the function
> a2mp_chan_recv_cb.
> 
> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
> ---
> net/bluetooth/a2mp.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
