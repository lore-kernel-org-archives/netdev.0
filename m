From: "David S. Miller" <davem@redhat.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Mon, 10 Nov 2003 18:29:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031110182911.2c5a121b.davem@redhat.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: johnip@sgi.com
In-Reply-To: <3FB03A56.7000709@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 10 Nov 2003 19:24:38 -0600
John Partridge <johnip@sgi.com> wrote:

> Please can you look at this. I'm not too sure about the Kconfig entry as I have not done one before :-

It belongs in arch/${ARCH}/Kconfig not drivers/net/Kconfig

It's a static property of the architecture, not something the
user chooses one way or the other.
