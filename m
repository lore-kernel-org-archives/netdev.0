From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Fwd: Receiving MLDv1 reports in a daemon]
Date: Tue, 16 Mar 2004 07:04:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4057176D.8050206@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080106080304070400020808"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080106080304070400020808
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ah, sorry, my bad. I cc'd netdev in my first response
but cut down the actual post.

thanks,
Nivedita


-------- Original Message --------
Subject: Receiving MLDv1 reports in a daemon
Date: Tue, 16 Mar 2004 16:38:25 +0530 (IST)
From: Madhavi <madhavis@sasken.com>
To: <linux-kernel@vger.kernel.org>


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



--------------080106080304070400020808
Content-Type: text/plain;
 name="file:///C|/DOCUME%7E1/NIVEDITA/LOCALS%7E1/TEMP/nsmail-1.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="file:///C|/DOCUME%7E1/NIVEDITA/LOCALS%7E1/TEMP/nsmail-1.txt"

***********************************************************************

********************************************************************

SASKEN BUSINESS DISCLAIMER

This message may contain confidential, proprietary or legally Privileged information. In case you are not the original intended Recipient of the message, you must not, directly or indirectly, use, Disclose, distribute, print, or copy any part of this message and you are requested to delete it and inform the sender. Any views expressed in this message are those of the individual sender unless otherwise stated. Nothing contained in this message shall be construed as an offer or acceptance of any offer by Sasken Communication Technologies Limited ("Sasken") unless sent with that express intent and with due authority of Sasken. Sasken has taken enough precautions to prevent the spread of viruses. However the company accepts no liability for any damage caused by any virus transmitted by this email.

***********************************************************************


--------------080106080304070400020808--
