From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] ieee802154: ca8210: Fix a potential NULL pointer
 dereference
Date: Sun, 20 Aug 2017 20:52:21 +0200
Message-ID: <ECF0BF4F-CBFA-42B2-9976-C268ADF1EA10@holtmann.org>
References: <20170820162502.4342-1-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Harry Morris <h.morris@cascoda.com>, linuxdev@cascoda.com,
        Alexander Aring <alex.aring@gmail.com>,
        Stefan Schmidt <stefan@osg.samsung.com>,
        linux-wpan@vger.kernel.org, Netdev list <netdev@vger.kernel.org>,
        kernel list <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170820162502.4342-1-christophe.jaillet@wanadoo.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christophe,

> 'spi' is known to be NULL, so we dereference a NULL pointer here.
> Use 'pr_crit()' instead of 'dev_crit()' to report the message.
> 
> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
> ---
> drivers/net/ieee802154/ca8210.c | 5 +----
> 1 file changed, 1 insertion(+), 4 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
