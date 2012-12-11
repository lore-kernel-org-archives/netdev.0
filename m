From: Peter Hurley <peter@hurleysoftware.com>
Subject: Re: netconsole fun
Date: Tue, 11 Dec 2012 09:19:52 -0500
Message-ID: <1355235592.2694.5.camel@thor>
References: <1355149033.3142.14.camel@thor> <ka6e4e$6k5$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout39.mail01.mtsvc.net ([216.70.64.83]:49782 "EHLO
	n12.mail01.mtsvc.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753334Ab2LKOUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2012 09:20:00 -0500
In-Reply-To: <ka6e4e$6k5$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-11 at 04:51 +0000, Cong Wang wrote:
> On Mon, 10 Dec 2012 at 14:17 GMT, Peter Hurley <peter@hurleysoftware.com> wrote:
> > Now that netpoll has been disabled for slaved devices, is there a
> > recommended method of running netconsole on a machine that has a slaved
> > device?
> >
> 
> Yes, running it on the master device instead.

Thanks for the suggestion, but:

[ 0.000000] Kernel command line: BOOT_IMAGE=/boot/vmlinuz-3.7.0-rc8-xeon ...... netconsole=@192.168.10.99/br0,30000@192.168.10.100/xx:xx:xx:xx:xx:xx
...
[ 5.289869] netpoll: netconsole: local port 6665
[ 5.289885] netpoll: netconsole: local IP 192.168.10.99
[ 5.289892] netpoll: netconsole: interface 'br0'
[ 5.289898] netpoll: netconsole: remote port 30000
[ 5.289907] netpoll: netconsole: remote IP 192.168.10.100
[ 5.289914] netpoll: netconsole: remote ethernet address xx:xx:xx:xx:xx:xx
[ 5.289922] netpoll: netconsole: br0 doesn't exist, aborting
[ 5.289929] netconsole: cleaning up
...
[ 9.392291] Bridge firewalling registered
[ 9.396805] device eth1 entered promiscuous mode
[ 9.418350] eth1:  setting full-duplex.
[ 9.421268] br0: port 1(eth1) entered forwarding state
[ 9.423354] br0: port 1(eth1) entered forwarding state


Is there a way to control or associate network device names prior to
udev renaming?

Thanks again,
Peter
