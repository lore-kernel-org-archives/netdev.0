From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Bug#267342: kernel-image-2.6.8-1-686-smp: TCP/IP strangeness
 in 2.6.8
Date: Wed, 25 Aug 2004 14:14:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <412D0152.1040509@us.ibm.com>
References: <20040822021929.E9D04212D@maus.private.neotoma.org> <20040825144808.GA10396@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kristine Diana Daniels <kddaniel@private.neotoma.org>,
        267342@bugs.debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20040825144808.GA10396@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> Could it be possible OpenBSD doesn't properly deal with the tcp window
> scaling changes in 2.6.8? (http://lwn.net/Articles/92727/)

Unless there is present in the path one of those broken
routers (mangling the window scale option), it's likely
something else. Also, nntp traffic tends to be small and
unaffected by window sizes. Any way to tell if that is so?

Any chance you could make the tcpdumps available, if
this has not already been resolved?

We had a problem with sshd and other apps hanging due
to glibc changes and unsafe signal handling in daemons,
but this seems like something else..

thanks,
Nivedita


>>I have noticed strangeness with the 2.6.8 kernel on both 686-smp
>>and k7.
>>1) rsync from 2.6.8 to a 2.6.7 host hangs.
>>2) ssh from 2.6.8 to a 2.6.7 host hangs.
>>3) nntp from 2.6.8 hangs for 52 seconds before proceeding.
>>4) ssh from Openbsd to 2.6.8 hangs after SSH2_MSG_KEX_DH_GEX_REQUEST
>>
>>In 1-2 the network topology is as follows
>>2.6.8host <-ethernet-> OpenBSD <-openvpn-> OpenBSD <-ethernet-> 2.6.7host
>>In 3 the network topology is as follows
>>2.6.8host <-ethernet-> OpenBSD <-openvpn-> OpenBSD <-internet-> nntp-server
>>In 4 the network topology is as follows
>>2.6.8host <-ethernet-> OpenBSD
