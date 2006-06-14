From: Phillip Susi <psusi@cfl.rr.com>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 14 Jun 2006 10:27:13 -0400
Message-ID: <44901CC1.60403@cfl.rr.com>
References: <1150278004.26181.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl, russell-tcatm@stuart.id.au, hawk@diku.dk,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iriserv.iradimed.com ([69.44.168.233]:34164 "EHLO iradimed.com")
	by vger.kernel.org with ESMTP id S964978AbWFNO21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jun 2006 10:28:27 -0400
To: Jesper Dangaard Brouer <hawk@comx.dk>
In-Reply-To: <1150278004.26181.35.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> The Linux traffic's control engine inaccurately calculates
> transmission times for packets sent over ADSL links.  For
> some packet sizes the error rises to over 50%.  This occurs
> because ADSL uses ATM as its link layer transport, and ATM
> transmits packets in fixed sized 53 byte cells.
> 

I could have sworn that DSL uses its own framing protocol that is 
similar to the frame/superframe structure of HDSL ( T1 ) lines and over 
that you can run ATM or ethernet.  Or is it typically ethernet -> ATM -> 
HDSL?

In any case, why does the kernel care about the exact time that the IP 
packet has been received and reassembled on the headend?


