From: "arun" <akumar@omnesysindia.com>
Subject: Re: SIOCETHTOOL history ?
Date: Tue, 6 May 2003 18:54:43 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <009901c313d2$db6b0630$243205c0@otp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


----- Original Message ----- 
From: "arun" <akumar@omnesysindia.com>
To: "David S. Miller" <davem@redhat.com>
Sent: Tuesday, May 06, 2003 6:53 PM
Subject: Re: SIOCETHTOOL history ?


> ----- Original Message ----- 
> From: "David S. Miller" <davem@redhat.com>
> To: <akumar@omnesysindia.com>
> Cc: <netdev@oss.sgi.com>
> Sent: Tuesday, May 06, 2003 5:19 PM
> Subject: Re: SIOCETHTOOL history ?
>  
 > Yes it does:
 
 Iam really stumped in that case since, mii-diag tool based
 on Donald Beckers code, ftp://ftp.scyld.com/pub/diag/mii-diag.c
 seems to work ok without CAP_NET_ADMIN on RH 7.1 
 and RH8.0 distros. 
 
 (I dont set any capabilities just tried to read speed / card id
 and it never returned EPERM for me)
 
 I chanced on the ethtool since mii failed to report anything on
 newer Gigabit cards (specifically a Broadcom Corporation 
 NetXtreme BCM5701 card)
 
 However ethtool required running with su root even for reading
 the capabilities (I recompiled ethtool code with only a GSET 
 command to confirm this) and that is why i have this doubt on the
 reason of the behavioural differnces between the 2 ioctl's
 
 arun
 
 
