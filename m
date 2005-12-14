From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] skge: get rid of warning on race
Date: Wed, 14 Dec 2005 00:37:08 -0500
Message-ID: <20051214053708.GA10486@redhat.com>
References: <200512130559.jBD5xUjf015319@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751372AbVLNFhW@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200512130559.jBD5xUjf015319@hera.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 12, 2005 at 09:59:30PM -0800, Linux Kernel wrote:
 > tree 987cfbd2134b82bea55c55fa17bd70d29df70458
 > parent 0e670506668a43e1355b8f10c33d081a676bd521
 > author Stephen Hemminger <shemminger@osdl.org> Wed, 07 Dec 2005 07:01:49 -0800
 > committer Jeff Garzik <jgarzik@pobox.com> Tue, 13 Dec 2005 09:33:03 -0500
 > 
 > [PATCH] skge: get rid of warning on race
 > 
 > Get rid of warning in case of race with ring full and lockless
 > tx on the skge driver. It is possible to be in the transmit
 > routine with no available slots and already stopped.
 > 
 > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 > Signed-off-by: Jeff Garzik <jgarzik@pobox.com>

You've traded a warning for something more serious :)

now I get...

drivers/net/skge.ko needs unknown symbol netif_stopped


		Dave
