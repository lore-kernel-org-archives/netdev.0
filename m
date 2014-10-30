From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [patch] Bluetooth: 6lowpan: use after free in disconnect_devices()
Date: Thu, 30 Oct 2014 09:24:23 -0700
Message-ID: <3DFF075B-22A1-4E52-8675-00207AE385C4@holtmann.org>
References: <20141029161057.GF5290@mwanda>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141029161057.GF5290@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

> This was accidentally changed from list_for_each_entry_safe() to
> list_for_each_entry() so now it has a use after free bug.  I've changed
> it back.
> 
> Fixes: 90305829635d ('Bluetooth: 6lowpan: Converting rwlocks to use RCU')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

patch has been applied to bluetooth-next tree.

Regards

Marcel
