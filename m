From: "Kevin McCarthy" <kevin@intrameta.com>
Subject: VIA Velocity RC4 test report
Date: Sun, 17 Oct 2004 10:29:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4F07B3611CD7FA4CA11A6176501B1DA863E1@senegal.corp.im>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: "Kris Efland" <kris@intrameta.com>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>, <romieu@fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

We found the RC4 to work much better than RC3.

Pre-RC3, loading the module on init caused Oops.

RC3 loaded fine on boot but any activity soon flooded the PHY and took
down an entire switch. It is possible the NIC detected gigabit when it
was plugged into a 100MBit switch but I am not sure.

RC4 has been working very well so far (24 hours).

Thanks,
Kevin
