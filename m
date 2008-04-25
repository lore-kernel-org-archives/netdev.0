From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netxen: reduce stack usage of netxen_nic_flash_print
Date: Fri, 25 Apr 2008 02:04:09 -0400
Message-ID: <48117459.4050903@garzik.org>
References: <1208890115.24124.3.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57214 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755576AbYDYGEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:04:14 -0400
In-Reply-To: <1208890115.24124.3.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harvey Harrison wrote:
> Don't need to keep a struct netxen_new_user_info on the stack
> when we only are interested in printing the serial_num.  Change
> to only reading the serial_num.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

applied


