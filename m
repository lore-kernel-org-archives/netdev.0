From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Bluetooth patches for 2.6.24
Date: Sat, 20 Oct 2007 22:01:37 +0200
Message-ID: <1192910497.6184.134.camel@violet>
References: <1192888816.6184.117.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([217.160.111.169]:58764 "EHLO
	mail.holtmann.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbXJUBhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2007 21:37:52 -0400
In-Reply-To: <1192888816.6184.117.camel@violet>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

> these are the Bluetooth patches for the 2.6.24 kernel release. Please
> pull and send them to Linus.

one of the cleanup patches slipped through the net. If you already
pulled my tree, then please re-pull. I pushed it on top of it.

Regards

Marcel


Please pull from

        git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git

This will update the following files:

 net/bluetooth/rfcomm/core.c |   60 +++++++++++++++-----------------------------
 1 file changed, 21 insertions(+), 39 deletions(-)

through these ChangeSets:

Commit: 58876e6a3dac244ca8d61f3b9750a3fb63875eff 
Author: Marcel Holtmann <marcel@holtmann.org> Sat, 20 Oct 2007 21:37:20 +0200 

    [Bluetooth] Convert RFCOMM to use kthread API
    
    This patch does the full kthread conversion for the RFCOMM protocol. It
    makes the code slightly simpler and more maintainable.
    
    Based on a patch from Christoph Hellwig <hch@lst.de>
    
    Signed-off-by: Marcel Holtmann <marcel@holtmann.org>



