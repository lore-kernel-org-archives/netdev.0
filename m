From: "J. M." <snortwiz@hotmail.com>
Subject: RE: OSDL Bugzilla #2399: A user can remotely route a packet through eth0 on a Li
Date: Thu, 13 May 2004 12:16:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BAY15-F23oD2goa4pNv00053eea@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: niv@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jan@ixiacom.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Applicable snip of netstat -lnp output:

Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State    
    PID/Program name
tcp        0      0 10.10.10.10:22          0.0.0.0:*               LISTEN   
    2836/sshd

No, ip_forward probably doesn't apply, but this is my first bug post so I 
figured I'd better include anything remotely possible :)

-Jared


>From: Jan Olderdissen <jan@ixiacom.com>
>To: netdev@oss.sgi.com
>CC: snortwiz@hotmail.com, 'Nivedita Singhvi' <niv@us.ibm.com>
>Subject: RE: OSDL Bugzilla #2399: A user can remotely route a packet 
>through eth0 on a Linux machine
>Date: Tue, 11 May 2004 11:44:42 -0700
>MIME-Version: 1.0
>Received: from racerx.ixiacom.com ([64.60.75.69]) by mc8-f42.hotmail.com 
>with Microsoft SMTPSVC(5.0.2195.6824); Tue, 11 May 2004 11:45:06 -0700
>Received: by racerx.ixiacom.com with Internet Mail Service (5.5.2657.72)id 
><JTCQGADG>; Tue, 11 May 2004 11:44:43 -0700
>X-Message-Info: 6sSXyD95QpVUIaPMW1t2diBZvRcT4xCR
>Message-ID: <15FDCE057B48784C80836803AE3598D50627ACCF@racerx.ixiacom.com>
>X-Mailer: Internet Mail Service (5.5.2657.72)
>Return-Path: jan@ixiacom.com
>X-OriginalArrivalTime: 11 May 2004 18:45:08.0007 (UTC) 
>FILETIME=[14F7A370:01C43788]
>
>Jared,
>
>I can't shake the feeling that the service didn't actually bind to eth1, 
>but
>instead bound to INADDR_ANY. You can find out with 'netstat -lnp'. Would 
>you
>mind posting the output?
>
> > A 'cat' or
> > /proc/sys/net/ipv4/ip_forward
> > on the Linux laptop was "0" so ip forwarding was not enabled.
>
>I don't think the ip_forward flag applies here.
>
>Jan

_________________________________________________________________
Check out the coupons and bargains on MSN Offers! http://youroffers.msn.com
