From: Pedro Fortuna <pedro.fortuna@gmail.com>
Subject: Re: filtering packtes before OS takes care about them
Date: Sat, 5 Mar 2005 14:08:56 +0000
Message-ID: <db95d40c0503050608e1e98d9@mail.gmail.com>
References: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
	 <7bca1cb50502281209798e8a00@mail.gmail.com>
Reply-To: Pedro Fortuna <pedro.fortuna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Asim Shankar <asimshankar@gmail.com>
In-Reply-To: <7bca1cb50502281209798e8a00@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Asim,
I wasnt able to compile your packet_type_test.c :( I even tried your
scripts (i.e. make-native.sh and make-uml.sh), which seem to me that
proceeded to compile the example against the kernel source (which I
have installed and in place), but all I got was a huge list of errors
and warnings, and no .o compiled in the end.

./make-native.sh modules
./make-uml.sh modules

I used ubuntu 4.10 with kernel 2.6.8.1-3 and kernel source 2.6.8.1.

Any clues?
Thanks. 
-Pedro Fortuna

On Mon, 28 Feb 2005 14:09:56 -0600, Asim Shankar <asimshankar@gmail.com> wrote:
> > i need a possibility to catch IP4 packets (from ethernet devices) before OS' netmodules (IP, UDP, TCP, ICMP, ARP, ROUTE, NETFILTER ...) takes care about them and
> > * to delete them from input buffer such that OS' netmodules can't receive them
> > * to modify packet headers and move packets to interface related output buffers
> > * to keep them in input buffers such that OS' netmodules can take care about them.
> 
> You can process packets even before ip_rcv() gets them by registering
> your own packet handler (struct packet_type) using dev_add_pack().  I
> have a small sample at:
> http://limnos.csrd.uiuc.edu/notes/code-samples/samples/kernel/packet_type/packet_type_test.c
> This may not be the cleanest way, but it isn't that dirty either.
> 
> Also see:
> http://www.phrack.org/show.php?p=55&a=12
> 
> -- Asim
> 
>
