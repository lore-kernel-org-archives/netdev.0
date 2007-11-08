From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] qla3xxx:  bugfix: Move link state machine into a
	worker thread
Date: Thu, 8 Nov 2007 12:47:47 -0500
Message-ID: <20071108174747.GD3011@havoc.gtf.org>
References: <20071107215608.GB7090@linux-7mw0.qlogic.org> <1194472747331-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:55653 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760099AbXKHRrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 12:47:47 -0500
Content-Disposition: inline
In-Reply-To: <1194472747331-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 01:59:06PM -0800, Ron Mercer wrote:
> The link state machine requires access to some resources that
> are shared with the iSCSI function on the chip.  (See iSCSI
> driver at drivers/scsi/qla4xxx)  If the interface is being
> up/downed at a rapid pace this driver may need to sleep
> waiting to get access to the common resources. For this we
> are moving the state machine to run as a work thread.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qla3xxx.c |   27 +++++++++++++--------------
>  drivers/net/qla3xxx.h |    1 +
>  2 files changed, 14 insertions(+), 14 deletions(-)

applied 1-2

