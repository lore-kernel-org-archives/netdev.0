From: Jan Olderdissen <jan@ixiacom.com>
Subject: RE: OSDL Bugzilla #2399: A user can remotely route a packet throu
	gh eth0 on a Linux machine
Date: Tue, 11 May 2004 11:44:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15FDCE057B48784C80836803AE3598D50627ACCF@racerx.ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: snortwiz@hotmail.com, "'Nivedita Singhvi'" <niv@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jared,

I can't shake the feeling that the service didn't actually bind to eth1, but
instead bound to INADDR_ANY. You can find out with 'netstat -lnp'. Would you
mind posting the output?

> A 'cat' or 
> /proc/sys/net/ipv4/ip_forward
> on the Linux laptop was "0" so ip forwarding was not enabled.

I don't think the ip_forward flag applies here. 

Jan
