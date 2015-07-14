From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 4/6] net: ieee802154: Remove redundant spi driver bus initialization
Date: Tue, 14 Jul 2015 07:07:31 +0200
Message-ID: <37171F2A-C41E-476A-A07C-72249A1757A5@holtmann.org>
References: <1435070714-24174-1-git-send-email-borneo.antonio@gmail.com> <1435071172-24542-1-git-send-email-borneo.antonio@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan@signal11.us>,
	Alexander Aring <alex.aring@gmail.com>,
	Varka Bhadram <varkabhadram@gmail.com>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Antonio Borneo <borneo.antonio@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435071172-24542-1-git-send-email-borneo.antonio@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Antonio,

> In ancient times it was necessary to manually initialize the bus
> field of an spi_driver to spi_bus_type. These days this is done in
> spi_register_driver(), so we can drop the manual assignment.
> 
> Signed-off-by: Antonio Borneo <borneo.antonio@gmail.com>
> To: Alan Ott <alan@signal11.us>
> To: Alexander Aring <alex.aring@gmail.com>
> To: Varka Bhadram <varkabhadram@gmail.com>
> To: linux-wpan@vger.kernel.org
> To: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> ---
> drivers/net/ieee802154/cc2520.c   | 1 -
> drivers/net/ieee802154/mrf24j40.c | 1 -
> 2 files changed, 2 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
