From: Anton <Anton.Uzunov@dsto.defence.gov.au>
Subject: Sending ipv6 packets from a kernel module
Date: Mon, 21 May 2007 14:04:33 +0930
Message-ID: <46512159.8080501@dsto.defence.gov.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from digger1.defence.gov.au ([203.5.217.4]:57501 "EHLO
	digger1.defence.gov.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338AbXEUEeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 00:34:46 -0400
Received: from ednmsw510.dsto.defence.gov.au (ednmsw510.dsto.defence.gov.au [131.185.68.11])
	by digger1.defence.gov.au (8.13.8/8.13.8) with ESMTP id l4L4P84V027764
	for <netdev@vger.kernel.org>; Mon, 21 May 2007 13:55:08 +0930 (CST)
Received: from ednex510.dsto.defence.gov.au (ednex510.dsto.defence.gov.au) by
    ednmsw510.dsto.defence.gov.au (Clearswift SMTPRS 5.2.5) with ESMTP id
    <T7fbb5d0b0a83b9440b15bc@ednmsw510.dsto.defence.gov.au> for
    <netdev@vger.kernel.org>; Mon, 21 May 2007 14:04:43 +0930
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Please excuse me if the following question has already been asked on the 
mailing list, I am a little new to this.

I am trying to send IPv6 packets from a kernel module. As far as I 
understand, I would have to use the ip6_output() function, and this 
function is certainly present in the net/ipv6/ip6_output.c file (on my
2.6.18 kernel). Unfortunately, the function is not exported from the
IPv6 module and so my kernel module is unable to use it. Has anyone 
encountered such a problem before, and if not, does anyone know what is 
required for me to push a sk_buff into the IP stack for transmission 
(from a kernel module)?
Any ideas would be appreciated!

Regards,
Anton



----------

IMPORTANT: This email remains the property of the Australian Defence 
Organisation and is subject to the jurisdiction of section 70 of the 
CRIMES ACT 1914.  If you have received this email in error, you are 
requested to contact the sender and delete the email.


