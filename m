From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH iproute-3.8 0/6] ip netns bug fixes and enhancements
Date: Wed, 6 Feb 2013 16:56:27 -0800
Message-ID: <CAGK4HS_nZ-fk5628wgHke0491ESLaZumSj1ALqDamd4bzBYfBg@mail.gmail.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:64905 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755302Ab3BGBBx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 20:01:53 -0500
Received: by mail-qa0-f48.google.com with SMTP id j8so947873qah.0
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 17:01:52 -0800 (PST)
In-Reply-To: <87622v5ngt.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Eric W. Biederman (6):
>       iproute2: Don't propogate mounts out of ip netns exec.
>       iproute2: Normalize return codes in "ip netns"
>       iproute2: Improve "ip netns add" failure error message
>       iproute2: Make "ip netns delete" more likely to succeed
>       iproute2: Fill in the ip-netns.8 manpage
>       iproute2: Add "ip netns pids" and "ip netns identify"
>


Eric,
With these patches applied, I am getting the following errors:


make[1]: Entering directory `/root/tools/iproute2/ip'
gcc -Wall -Wstrict-prototypes -Werror -O2 -I../include
-DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2=
\"
-D_GNU_SOURCE   -c -o ipaddress.o ipaddress.c
gcc -Wall -Wstrict-prototypes -Werror -O2 -I../include
-DRESOLVE_HOSTNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2=
\"
-D_GNU_SOURCE   -c -o ipnetns.o ipnetns.c
ipnetns.c: In function =91netns_exec=92:
ipnetns.c:156: error: =91MS_SLAVE=92 undeclared (first use in this func=
tion)
ipnetns.c:156: error: (Each undeclared identifier is reported only once
ipnetns.c:156: error: for each function it appears in.)
ipnetns.c:156: error: =91MS_REC=92 undeclared (first use in this functi=
on)
ipnetns.c: In function =91netns_add=92:
ipnetns.c:372: error: =91MS_SHARED=92 undeclared (first use in this fun=
ction)
ipnetns.c:372: error: =91MS_REC=92 undeclared (first use in this functi=
on)
make[1]: *** [ipnetns.o] Error 1
make[1]: Leaving directory `/root/tools/iproute2/ip'
make: *** [all] Error 2


Thanks,
Vijay
