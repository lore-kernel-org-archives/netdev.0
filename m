From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Fix oops caused by tcp_v4_md5_do_del
Date: Sun, 17 Dec 2006 17:12:45 -0800 (PST)
Message-ID: <20061217.171245.11054331.davem@davemloft.net>
References: <45575.81.105.127.245.1166053430.squirrel@www.solinno.co.uk>
	<20061213.162235.21925707.davem@davemloft.net>
	<45953.81.105.127.245.1166363085.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49661
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751219AbWLRBMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 20:12:44 -0500
To: leigh@solinno.co.uk
In-Reply-To: <45953.81.105.127.245.1166363085.squirrel@www.solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Leigh Brown" <leigh@solinno.co.uk>
Date: Sun, 17 Dec 2006 13:44:45 -0000 (GMT)

> md5sig_info.alloced4 must be set to zero when freeing keys4, otherwise
> it will not be alloc'd again when another key is added to the same
> socket by tcp_v4_md5_do_add.
> 
> Signed-off-by: Leigh Brown <leigh@solinno.co.uk>

Applied, thanks for fixing this Leigh.
