From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Tue, 14 Oct 2003 09:53:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014095323.71c8b9fe.davem@redhat.com>
References: <3F844578.40306@sgi.com>
	<20031008101046.376abc3b.davem@redhat.com>
	<3F8455BE.8080300@sgi.com>
	<20031008183742.GA24822@wotan.suse.de>
	<20031008122223.1ba5ac79.davem@redhat.com>
	<20031008202248.GA15611@oldwotan.suse.de>
	<3F8702FF.70500@sgi.com>
	<20031010192036.GA31727@wotan.suse.de>
	<3F8802E6.5030601@sgi.com>
	<20031011131921.GC21763@wotan.suse.de>
	<20031011105054.0e16a607.davem@redhat.com>
	<3F8C290A.3010508@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, modica@sgi.com, netdev@oss.sgi.com, jgarzik@pobox.com,
        jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnip@sgi.com
In-Reply-To: <3F8C290A.3010508@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Oct 2003 11:49:14 -0500
John Partridge <johnip@sgi.com> wrote:

> I do propose that we make the CONFIG a little more descriptive something like
> 
>   CONFIG_5701PCIX_UNALIGNED_EXPENSIVE
> 
> just to make it easier for users to see what it does.

That's grosser than gross.

We're trying to create a generic mechanism to fix this kind of
problem in _ALL_ drivers.  I will heavily thwart any attempt to
make this some kind of "tg3 thing".
