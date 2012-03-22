From: "Prashant Batra (prbatra)" <prbatra@cisco.com>
Subject: Query regarding pf_packet sockets
Date: Thu, 22 Mar 2012 08:52:53 +0530
Message-ID: <B97B134FACB2024DB45F524AB0A7B7F2063EB8C6@XMB-BGL-419.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-1.cisco.com ([72.163.197.25]:54417 "EHLO
	bgl-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752184Ab2CVDcu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 23:32:50 -0400
Received: from xbh-bgl-412.cisco.com (xbh-bgl-412.cisco.com [72.163.129.202])
	by bgl-core-1.cisco.com (8.14.3/8.14.3) with ESMTP id q2M3MvhS023569
	for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 03:22:57 GMT
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,

I am trying to use PF_PACKET socket along with filters applied on the s=
ocket through setsockopt, SO_ATTACH_FILTER.
Now as I create this socket, any packet coming to the kernel would be c=
opied into the socket buffer for this socket.

So, even if I apply the filter, first few packets would always be those=
 which do not match the filter.=20

Is there a way (some socket option), =A0to make socket passive and acti=
ve, so that I will set the socket in passive mode after creation,=20
and then set it as active, after I apply the filter, so that I only rec=
eive the filtered packet in user space.

Thanks,
Prashant
