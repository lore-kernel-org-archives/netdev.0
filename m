From: "santosh kumar gowda" <ipv6_san@rediffmail.com>
Subject: Re: Re: Re: Re: IPv6 enabled Network services
Date: 13 Feb 2003 13:05:14 -0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030213130514.7494.qmail@webmail17.rediffmail.com>
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

Ooops...i still have some problem

 From machine-1 with Linux version 2.4.18-3smp gcc version 2.96,
  Red Hat Linux 7.3,

telnet>feco::102:304:5678
Trying feco::102:304:5678
telnet: connect to address feco::102:304:5678: Connection 
refused

why am i getting connection refused ??

and machine-2 with Linux version 2.4.18-14 (gcc version 3.2
20020903 (Red Hat Linux 8.0 3.2-7),

telnet>feco::102:304:1357
feco::102:304:1357/28: Unknown host

Response from machine-2 is quite differnet than machine-1. why 
??

thanx,
San
----------------------------------------

On Thu, 13 Feb 2003 Peter Bieringer wrote :
>
>
>--On Thursday, February 13, 2003 11:15:57 AM +0000 santosh 
>kumar
>gowda <ipv6_san@rediffmail.com> wrote:
>
> > Dr.Peter,
> >
> > I'm able to ping (using ping6) from both the machines.
> >
> > But, when i perform telnet, in machine-1 with Linux version
> > 2.4.18-3smp gcc version 2.96, Red Hat Linux 7.3, i get
> >
> ># telnet fe80::2b0:d0ff:fed2:65ff
> > Trying fe80::2b0:d0ff:fed2:65ff
> > telnet: connect to address fe80::2b0:d0ff:fed2:65ff: Invalid
> > argument
> >
> > And the machine-2 with Linux version 2.4.18-14 (gcc version 
>3.2
> > 20020903 (Red Hat Linux 8.0 3.2-7), i get
> >
> ># telnet fe80::250:daff:fed2:d90e
> > fe80::250:daff:fed2:d90e: Unknown host
> >
> > In case, if i need to upgrade telnet, ftp, etc, suggest me 
>where i
> > can find them. Any docs for the same. looking forward for ur 
>help
>
>Grmmml, read FAQ in HowTo: do not use link-local addresses for 
>normal
>purposes, they won't work because of the scoping issue. Configure 
>and
>use site-local instead.
>
>         Peter
>--
>Dr. Peter Bieringer                     
>http://www.bieringer.de/pb/
>GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot 
>de
>Deep Space 6 Co-Founder and Core Member  
>http://www.deepspace6.net/
