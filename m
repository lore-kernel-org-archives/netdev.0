From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: Re: Re: Re: IPv6 enabled Network services
Date: 13 Feb 2003 11:15:57 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030213111557.21921.qmail@webmail27.rediffmail.com>
Reply-To: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Peter Bieringer" <pb@bieringer.de>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dr.Peter,

I'm able to ping (using ping6) from both the machines.

But, when i perform telnet, in machine-1 with Linux version 
2.4.18-3smp gcc version 2.96, Red Hat Linux 7.3, i get

# telnet fe80::2b0:d0ff:fed2:65ff
Trying fe80::2b0:d0ff:fed2:65ff
telnet: connect to address fe80::2b0:d0ff:fed2:65ff: Invalid 
argument

And the machine-2 with Linux version 2.4.18-14 (gcc version 3.2
20020903 (Red Hat Linux 8.0 3.2-7), i get

#telnet fe80::250:daff:fed2:d90e
fe80::250:daff:fed2:d90e: Unknown host

In case, if i need to upgrade telnet, ftp, etc, suggest me where i 
can find them. Any docs for the same.
looking forward for ur help

-San
---------------------------------------------
On Thu, 13 Feb 2003 Peter Bieringer wrote :
>
>
>--On Thursday, February 13, 2003 08:52:38 AM +0000 santosh 
>kumar
>gowda <ipv6_san@rediffmail.com> wrote:
>
> > Hi Marc
> > i tried for
> > telnet> 3ffe::102:304:1234
> > still i get
> > 3ffe::102:304:1234: unknown host
>
>Can you ping6 this address? Are the shown addresses configured 
>in
>real or are they rewritten for public ML posting?
>
>They look a little bit strange to me.
>
>Also try
>$ telnet <ipv6address>
>
>perhaps this kind will work.
>
>If not, telnet has perhaps no IPv6 support (which version/RPM do 
>you
>use)? Check also
>$ which telnet
>to be sure you're using the right one.
>
>         Peter
>--
>Dr. Peter Bieringer                     
>http://www.bieringer.de/pb/
>GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot 
>de
>Deep Space 6 Co-Founder and Core Member  
>http://www.deepspace6.net/
>
>
