From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: TOE brain dump
Date: Mon, 4 Aug 2003 16:36:06 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030804163606.Q639@nightmaster.csn.tu-chemnitz.de>
References: <20030802140444.E5798@almesberger.net> <3F2BF5C7.90400@us.ibm.com> <3F2C0C44.6020002@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nivedita Singhvi <niv@us.ibm.com>,
	Werner Almesberger <werner@almesberger.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3F2C0C44.6020002@pobox.com>; from jgarzik@pobox.com on Sat, Aug 02, 2003 at 03:08:52PM -0400
List-Id: netdev.vger.kernel.org

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
