From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: sysfs tagged directory support status (was:. Re: [PATCH 1/8]
	sysfs: Implement sysfs tagged directory support)
Date: Sun, 5 Apr 2009 23:49:58 -0500
Message-ID: <20090406044958.GA8644@hallyn.com>
References: <dac45060904010300y7fe8a09dxb582929fc8018ec1@mail.gmail.com> <20090404030551.GC23516@suse.de> <dac45060904052128p6c539fe4p199a03f47a43a96b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, David Shwatrz <dshwatrz@gmail.com>,
	Tejun Heo <htejun@gmail.com>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Mark Ryden <markryde@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hrndva-omtalb.mail.rr.com ([71.74.56.125]:57309 "EHLO
	hrndva-omtalb.mail.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbZDFErF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 00:47:05 -0400
Content-Disposition: inline
In-Reply-To: <dac45060904052128p6c539fe4p199a03f47a43a96b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Mark Ryden (markryde@gmail.com):
> Hello,
> I am sorry to hear that it is not merged yet.I hoped to try to start a
> project with network namespaces.

Sysfs tagged directories are not supported, but with 2.6.29 you
can use network namespaces.  There are some limits - you can't
move a physical network device out of the initial network
namespace, and (veth) devices which are not in the initial
network namespace just don't show up in /sys/class/net (since
we can't tag them).

But you can use network namespaces.

-serge
