From: "Srivats P" <Srivats.P@conexant.com>
Subject: RE: Question about IP-in-IP tunneling
Date: Fri, 27 Feb 2009 09:45:21 +0530
Message-ID: <F33E0C3C2876A544ABD34CFBE345A4A4027BC08A94@NDMBX01.bbnet.ad>
References: <49A70476.8050300@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Santwona.Behera@Sun.COM" <Santwona.Behera@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnxtsmtp4.conexant.com ([198.62.9.251]:57180 "EHLO
	cnxtsmtp4.conexant.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754066AbZB0EO7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 23:14:59 -0500
Received: from CPS (wsmx2.nb.conexant.com [157.152.185.17]) (using TLSv1 with cipher RC4-MD5 (
 128/128 bits)) (No client certificate requested) by cnxtsmtp4.conexant.com (Tumbleweed MailGate
 3.6.1) with ESMTP id 239B419806BC for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 20:15:01 -0800 (
 PST)
In-Reply-To: <49A70476.8050300@Sun.COM>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Assuming the outer IP header is a IPv4 header, the protocol field of this IPv4 header has IPROTO_IPIP (4) when the inner header is IPv4 and IPPROTO_IPV6 (41) when the inner header is IPv6

Is that what you asked?

- Srivats

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Santwona.Behera@Sun.COM
Sent: Friday, February 27, 2009 2:37 AM
To: netdev@vger.kernel.org
Subject: Question about IP-in-IP tunneling

A question for the IP tunneling experts:

For IP-in-IP tunneling, what are the cases when IPROTO_IPIP (4) is used in the protocol field of the outer IP header and the cases when
IPPROTO_IPV6 (41) is used instead?

thanks,
--santwona
--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html

Conexant E-mail Firewall (Conexant.Com) made the following annotations
---------------------------------------------------------------------
********************** Legal Disclaimer **************************** 

"This email may contain confidential and privileged material for the sole use of the intended recipient. Any unauthorized review, use or distribution by others is strictly prohibited. If you have received the message in error, please advise the sender by reply email and delete the message. Thank you." 

********************************************************************** 

---------------------------------------------------------------------

