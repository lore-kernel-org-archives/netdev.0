From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: Broadcom 4400 driver bm44
Date: Thu, 8 Jul 2004 23:43:46 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708204346.GA28693@ee.oulu.fi>
References: <f3ddc6d3040707112141b20720@mail.gmail.com> <20040708133853.GA20254@ee.oulu.fi> <f3ddc6d304070807002a19d340@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Hubbard <jameshubbard@gmail.com>
Content-Disposition: inline
In-Reply-To: <f3ddc6d304070807002a19d340@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 08, 2004 at 10:00:26AM -0400, James Hubbard wrote:
> If I can make some time I'll look into writing a test case here also. 
> I just don't know when it will be though.  I've got the source for the
> net comms layer for the apps.  Perhaps I can pull out some code that
> may demonstrate the error.
> 
> Thanks for the help.
Ok, after some digging around ALLMULTI breaking is not a bug, the
vendor-provided driver seems to break in similar ways, at least on 2.6,
so that's a feature unless they fix it in theirs so I can copy the fix :-) 

I put a lots'o'debugging + some bit-flipping reordering to look
more like bcm4400 version at http://www.ee.oulu.fi/~pp/b44-test.tgz.
Probably won't fix the problem, but it's worth a shot I suppose.

Should compile with 

make -C /lib/modules/<version>/build modules SUBDIRS=$PWD

As a workaround I suppose ifconfig eth1 promisc might do the trick too.
