From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qmi_wwan/cdc_ether: move Novatel 551 and E362 to
 qmi_wwan
Date: Fri, 26 Oct 2012 03:44:45 -0400 (EDT)
Message-ID: <20121026.034445.1640490757070033659.davem@davemloft.net>
References: <1351103720.6544.34.camel@dcbw.foobar.com>
	<87objr659w.fsf@nemi.mork.no>
	<1351116634.16726.6.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, aleksander@gnu.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: dcbw@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44359 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756842Ab2JZHor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 03:44:47 -0400
In-Reply-To: <1351116634.16726.6.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Williams <dcbw@redhat.com>
Date: Wed, 24 Oct 2012 17:10:34 -0500

> These devices provide QMI and ethernet functionality via a standard CDC
> ethernet descriptor.  But when driven by cdc_ether, the QMI
> functionality is unavailable because only cdc_ether can claim the USB
> interface.  Thus blacklist the devices in cdc_ether and add their IDs to
> qmi_wwan, which enables both QMI and ethernet simultaneously.
> 
> Signed-off-by: Dan Williams <dcbw@redhat.com>

Applied, thanks.
