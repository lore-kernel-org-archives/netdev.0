From: Madhavi <madhavis@sasken.com>
Subject: Receiving MLDv1 reports in a daemon
Date: Wed, 17 Mar 2004 09:45:25 +0530 (IST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33.0403170944260.23954-100000@pcz-madhavis.sasken.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_IS_MIME_Boundary"
Cc: <madhavis@sasken.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=_IS_MIME_Boundary
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.33.0403170944262.23954@pcz-madhavis.sasken.com>


Hi

I am trying to incorporate the functionality of MLDv1 into a daemon. This
would be in addition to the functionality already supported by the kernel
IPv6 stack.

I am opening a raw socket with proto IPPROTO_ICMPV6 in my daemon process.
When I am sending an MLDv1 report from the host, the Router is able to
receive the report. But, I am not able to receive it over the socket.

I have checked the kernel code and found that the kernel is sending reports
only if the group address being reported is added to the device multicast
list. Since I won't know the group address in advance, I can't add it to
the device multicast list.

Is there any other way to get the MLDv1 reports to my daemon. Any solution
to this problem would be very helpful to me.

Thanks & regards
Madhavi.

Madhavi Suram
Senior Software Engineer
Customer Delivery / Networks
Sasken Communication Technologies Limited
139/25, Ring Road, Domlur
Bangalore - 560071 India
Email: madhavis@sasken.com
Tel: + 91 80 5355501 Extn: 8062
Fax: + 91 80 5351133
URL: www.sasken.com


--=_IS_MIME_Boundary
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

***********************************************************************

********************************************************************

SASKEN BUSINESS DISCLAIMER

This message may contain confidential, proprietary or legally Privileged information. In case you are not the original intended Recipient of the message, you must not, directly or indirectly, use, Disclose, distribute, print, or copy any part of this message and you are requested to delete it and inform the sender. Any views expressed in this message are those of the individual sender unless otherwise stated. Nothing contained in this message shall be construed as an offer or acceptance of any offer by Sasken Communication Technologies Limited ("Sasken") unless sent with that express intent and with due authority of Sasken. Sasken has taken enough precautions to prevent the spread of viruses. However the company accepts no liability for any damage caused by any virus transmitted by this email.

***********************************************************************

--=_IS_MIME_Boundary--
