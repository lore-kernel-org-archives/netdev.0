From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] skge: get rid of warning on race
Date: Tue, 13 Dec 2005 22:47:38 -0800 (PST)
Message-ID: <20051213.224738.130590565.davem@davemloft.net>
References: <200512130559.jBD5xUjf015319@hera.kernel.org>
	<20051214053708.GA10486@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@osdl.org,
	jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751266AbVLNGsX@vger.kernel.org>
To: davej@redhat.com
In-Reply-To: <20051214053708.GA10486@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dave Jones <davej@redhat.com>
Date: Wed, 14 Dec 2005 00:37:08 -0500

> drivers/net/skge.ko needs unknown symbol netif_stopped

it's a typo, it should be netif_queue_stopped(). :-/
