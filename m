From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH v2] Make builds default to quiet mode
Date: Tue, 31 May 2016 12:15:13 -0700
Message-ID: <20160531121513.416c48ae@xeon-e3>
References: <1464127489-5232-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:14159 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754592AbcEaTjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 15:39:08 -0400
In-Reply-To: <1464127489-5232-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 May 2016 15:04:49 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Similar to the Linux kernel and perf add infrastructure to reduce the
> amount of output tossed to a user during a build. Full build output
> can be obtained with 'make V=1'
> 
> Builds go from:
> 
> make[1]: Leaving directory `/home/dsa/iproute2.git/lib'
> make[1]: Entering directory `/home/dsa/iproute2.git/ip'
> gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -Wformat=2 -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE    -c -o ip.o ip.c
> gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -Wformat=2 -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE    -c -o ipaddress.o ipaddress.c
> 
> to:
> 
> ...
>     AR       libutil.a
> 
> ip
>     CC       ip.o
>     CC       ipaddress.o
> ...
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Looks good applied.
