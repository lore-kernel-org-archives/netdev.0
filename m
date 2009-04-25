From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: Loopback and net namespace
Date: Sat, 25 Apr 2009 09:00:53 -0500
Message-ID: <20090425140053.GA6224@hallyn.com>
References: <alpine.LNX.2.00.0904242322490.1162@duch.mimuw.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: emil@linux.org.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.122]:64798 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbZDYN6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 09:58:06 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.0904242322490.1162@duch.mimuw.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting emil@linux.org.pl (emil@linux.org.pl):
>
> Currently it is impossible to use both net namespace and sysfs
> because sysfs does not allow two devices with the same name
> and each net namespace has to have loopback device.

?  What kernel version are you on?  Try jumping to 2.6.29 or later
(and non-distro kernel).

It most certainly is possible to have net namespaces and sysfs.
Since sysfs tagged directories must wait until sysfs locking itself
is straightened out, the workaround was to have network devices
in a network namespace other than init not show up in sysfs.
(Physical devices therefore cannot be passed into non-init network
namespaces).

thanks,
-serge
