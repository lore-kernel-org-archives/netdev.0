From: James Hubbard <jameshubbard@gmail.com>
Subject: Re: Broadcom 4400 driver bm44
Date: Mon, 26 Jul 2004 09:49:55 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <f3ddc6d304072606495bf35e6a@mail.gmail.com>
References: <f3ddc6d3040707112141b20720@mail.gmail.com> <20040708133853.GA20254@ee.oulu.fi> <f3ddc6d304070807002a19d340@mail.gmail.com> <20040708204346.GA28693@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Pietikainen <pp@ee.oulu.fi>
In-Reply-To: <20040708204346.GA28693@ee.oulu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004 23:43:46 +0300, Pekka Pietikainen <pp@ee.oulu.fi> wrote:
> Ok, after some digging around ALLMULTI breaking is not a bug, the
> vendor-provided driver seems to break in similar ways, at least on 2.6,
> so that's a feature unless they fix it in theirs so I can copy the fix :-)
> 
> I put a lots'o'debugging + some bit-flipping reordering to look
> more like bcm4400 version at http://www.ee.oulu.fi/~pp/b44-test.tgz.
> Probably won't fix the problem, but it's worth a shot I suppose.
> 
> Should compile with
> 
> make -C /lib/modules/<version>/build modules SUBDIRS=$PWD
> 
> As a workaround I suppose ifconfig eth1 promisc might do the trick too.
> 

Hello,

Just to let you know, I've not forgotten about this problem.  I've got
another Dell laptop  that I can reproduce it on.  I'm going to try to
get the stock 2.6.7 kernel on it and try it out.  Hopefully I can get
you some more information by the end of the week.

James


-- 
James Hubbard
http://www.mcs.uvawise.edu/~jhubbard
