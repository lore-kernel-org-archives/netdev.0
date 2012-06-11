From: Thomas Graf <tgraf@infradead.org>
Subject: Re: Generic user-space routing library -- need collaborator
Date: Mon, 11 Jun 2012 04:09:08 -0400
Message-ID: <20120611080908.GB28598@canuck.infradead.org>
References: <4FCBBD6C.8020904@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: Philip Prindeville <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:32907 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695Ab2FKIJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 04:09:10 -0400
Content-Disposition: inline
In-Reply-To: <4FCBBD6C.8020904@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 03, 2012 at 01:39:24PM -0600, Philip Prindeville wrote:
> Hi.
> 
> I'm working on adding a few more portability classes to Poco (a multi-platform C++ toolkit) and wanted to add a Net::Routing class for examining and manipulating the routing tables.
> 
> The C++ would just be convenience wrappers around a core C library that handles the netlink semantics. I've looked at libmnl and it's handy, but I need a higher level of abstraction (for instance, parsing an RTA_NETMASK for IPv6 is anything but well-documented).

You want to look at libnl. It's similiar to libmnl but provides a higher
level of abstraction. It implements routing, netfilter and generic
netlink parsing and message construction.

http://www.infradead.org/~tgr/libnl/

You should be able to easily construct C++ wrappers around the lib.

~Thomas
