From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Tue, 11 Nov 2003 12:24:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111122403.2d7bcf28.davem@redhat.com>
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
	<20031014095323.71c8b9fe.davem@redhat.com>
	<3FB03A56.7000709@sgi.com>
	<20031110182911.2c5a121b.davem@redhat.com>
	<3FB140E2.1070007@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnip@sgi.com
In-Reply-To: <3FB140E2.1070007@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 11 Nov 2003 14:04:50 -0600
John Partridge <johnip@sgi.com> wrote:

> Is this OK ? I was not sure about the order should depends be beofre default or
> the other way round ? or does it matter ? I suspect it does.

Why are you depending upon MCKINLEY?  Don't all ia64 cpus
give traps for unaligned memory accesses?

That is what this CONFIG option tells the whole kernel.
