From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCHv4 1/1] bluetooth: Check for SCO type before setting retransmission effort
Date: Tue, 23 Sep 2014 11:32:01 +0200
Message-ID: <D6DCEC0F-76A0-4D5A-8B8A-D51F7F4449C7@holtmann.org>
References: <1411035321-10215-1-git-send-email-bernhard.thaler@r-it.at> <1411462867-4010-1-git-send-email-bernhard.thaler@r-it.at>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Bernhard Thaler <bernhard.thaler@r-it.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411462867-4010-1-git-send-email-bernhard.thaler@r-it.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Bernhard,

> SCO connection cannot be setup to devices that do not support retransmission.
> Patch based on http://permalink.gmane.org/gmane.linux.bluez.kernel/7779 and
> adapted for this kernel version.
> Code changed to check SCO/eSCO type before setting retransmission effort
> and max. latency. The purpose of the patch is to support older devices not
> capable of eSCO.
> 
> Tested on Blackberry 655+ headset which does not support retransmission.
> Credits go to Alexander Sommerhuber.
> 
> Signed-off-by: Bernhard Thaler <bernhard.thaler@r-it.at>
> ---
> net/bluetooth/hci_conn.c |   22 +++++++++++++++++-----
> 1 file changed, 17 insertions(+), 5 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
