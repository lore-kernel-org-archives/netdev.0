From: "Alan Shih" <alan@storlinksemi.com>
Subject: RE: TOE brain dump
Date: Mon, 4 Aug 2003 10:19:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <ODEIIOAOPGGCDIKEOPILEEOCDAAA.alan@storlinksemi.com>
References: <20030804163606.Q639@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Nivedita Singhvi" <niv@us.ibm.com>,
   "Werner Almesberger" <werner@almesberger.net>, <netdev@oss.sgi.com>,
   <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Ingo Oeser" <ingo.oeser@informatik.tu-chemnitz.de>,
   "Jeff Garzik" <jgarzik@pobox.com>
In-Reply-To: <20030804163606.Q639@nightmaster.csn.tu-chemnitz.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hmm,

So would main processor still need a copy of the data for re-transmission?
Won't that defeat the purpose?

Alan

-----Original Message-----
From: linux-kernel-owner@vger.kernel.org
[mailto:linux-kernel-owner@vger.kernel.org]On Behalf Of Ingo Oeser
Sent: Monday, August 04, 2003 7:36 AM
To: Jeff Garzik
Cc: Nivedita Singhvi; Werner Almesberger; netdev@oss.sgi.com;
linux-kernel@vger.kernel.org
Subject: Re: TOE brain dump


Hi Jeff,

On Sat, Aug 02, 2003 at 03:08:52PM -0400, Jeff Garzik wrote:
> So, fix the other end of the pipeline too, otherwise this fast network
> stuff is flashly but pointless.  If you want to serve up data from disk,
> then start creating PCI cards that have both Serial ATA and ethernet
> connectors on them :)  Cut out the middleman of the host CPU and host
> memory bus instead of offloading portions of TCP that do not need to be
> offloaded.

Exactly what I suggested: sys_ioroute()

"Providing generic pipelines and io routing as Linux service"
Msg-ID: <20030718134235.K639@nightmaster.csn.tu-chemnitz.de>

on linux-kernel and linux-fsdevel

Be my guest.

I know, that you mean doing it in hardware, but you cannot
accelerate sth. which the kernel doesn't do ;-)

Regards

Ingo Oeser
