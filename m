From: Santwona.Behera@Sun.COM
Subject: Re: Question about IP-in-IP tunneling
Date: Fri, 27 Feb 2009 09:14:16 -0800
Message-ID: <49A81F68.8040906@Sun.COM>
References: <49A70476.8050300@Sun.COM>
 <F33E0C3C2876A544ABD34CFBE345A4A4027BC08A94@NDMBX01.bbnet.ad>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Srivats P <Srivats.P@conexant.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:41266 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbZB0ROY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 12:14:24 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1RHEIA4005634
	for <netdev@vger.kernel.org>; Fri, 27 Feb 2009 09:14:18 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KFQ00M00HQH6300@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Fri,
 27 Feb 2009 09:14:18 -0800 (PST)
In-reply-to: <F33E0C3C2876A544ABD34CFBE345A4A4027BC08A94@NDMBX01.bbnet.ad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That does answer my question, thank you. Extending this to IPv6 as the 
outer header, is the next header field IPROTO_IPIP for IPv4 inner header 
and IPPROTO_IPV6 for IPv6 inner header?

thanks!
--santwona

On 02/26/09 08:15 PM, Srivats P wrote:
> Assuming the outer IP header is a IPv4 header, the protocol field of this IPv4 header has IPROTO_IPIP (4) when the inner header is IPv4 and IPPROTO_IPV6 (41) when the inner header is IPv6
> 
> Is that what you asked?
> 
> - Srivats
> 
> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Santwona.Behera@Sun.COM
> Sent: Friday, February 27, 2009 2:37 AM
> To: netdev@vger.kernel.org
> Subject: Question about IP-in-IP tunneling
> 
> A question for the IP tunneling experts:
> 
> For IP-in-IP tunneling, what are the cases when IPROTO_IPIP (4) is used in the protocol field of the outer IP header and the cases when
> IPPROTO_IPV6 (41) is used instead?
> 
> thanks,
> --santwona
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> Conexant E-mail Firewall (Conexant.Com) made the following annotations
> ---------------------------------------------------------------------
> ********************** Legal Disclaimer **************************** 
> 
> "This email may contain confidential and privileged material for the sole use of the intended recipient. Any unauthorized review, use or distribution by others is strictly prohibited. If you have received the message in error, please advise the sender by reply email and delete the message. Thank you." 
> 
> ********************************************************************** 
> 
> ---------------------------------------------------------------------
> 
