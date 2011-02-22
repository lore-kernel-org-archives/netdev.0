From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH ethtool 5/5] ethtool: Add --version option
Date: Tue, 22 Feb 2011 16:35:16 -0500
Message-ID: <4D642C14.6020505@garzik.org>
References: <1561212236.5138.1298355384916.JavaMail.root@tahiti.vyatta.com> <1298378228.2211.472.camel@localhost> <1298379945.2861.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:50840 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab1BVVfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 16:35:21 -0500
Received: by qyk7 with SMTP id 7so3311603qyk.19
        for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 13:35:20 -0800 (PST)
In-Reply-To: <1298379945.2861.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/22/2011 08:05 AM, Eric Dumazet wrote:
> Le mardi 22 f=C3=A9vrier 2011 =C3=A0 12:37 +0000, Ben Hutchings a =C3=
=A9crit :
>> On Mon, 2011-02-21 at 22:16 -0800, Stephen Hemminger wrote:
>> [...]
>>> The standard convention is to use -V for short form of version opti=
on.
>>
>> This is not anywhere near standard.
>>
>> $ cp -V
>> cp: invalid option -- 'V'
>> Try `cp --help' for more information.
>> $ bash -V
>> bash: -V: invalid option
>> [...]
>> $ emacs -V
>> [opens window]
>> $ vim -V
>> chdir(/usr/share/vim)
>> fchdir() to previous dir
>> sourcing "$VIM/vimrc"
>> [...looks like that meant 'verbose'...]
>
> Now try with networking tools, many use -V
>
> (As a matter of fact, ethtool -h already is used to display help)
>
> # ping -V
> ping utility, iputils-sss20071127
> # tc -V
> tc utility, iproute2-ss100823
> # ssh -V
> OpenSSH_5.1p1 Debian-5, OpenSSL 0.9.8g 19 Oct 2007

Stephen is correct, "-V" is a common standard (but by no means=20
universal).  The following is what using argp ("info argp") generates=20
for any program by default:

> Usage: myprog [OPTION...]
> myprog - a program that does something
>
> [...]
>
>   -?, --help                 Give this help list
>       --usage                Give a short usage message
>   -V, --version              Print program version
>
> Mandatory or optional arguments to long options are also mandatory or=
 optional for any corresponding short options.

Regards,

	Jeff


