From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH v3] can: Add driver for esd CAN-USB/2 device
Date: Wed, 26 May 2010 15:47:34 +0200
Message-ID: <201005261547.34596.oneukum@suse.de>
References: <201005261114.03214.matthias.fuchs@esd.eu>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Socketcan-core@lists.berlios.de,
	linux-usb@vger.kernel.org
To: Matthias Fuchs <matthias.fuchs@esd.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40710 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755137Ab0EZNrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 May 2010 09:47:25 -0400
In-Reply-To: <201005261114.03214.matthias.fuchs@esd.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 26. Mai 2010 11:14:03 schrieb Matthias Fuchs:
> +       netdev->trans_start = jiffies;
> +
> +       /* Slow down tx path */
> +       if (atomic_read(&priv->active_tx_jobs) >= MAX_TX_URBS)
> +               netif_stop_queue(netdev);

Where is the queue started again?

	Regards
		Oliver
