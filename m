From: Paul P <ppak_98@yahoo.com>
Subject: extra epollout events from edge triggered epoll
Date: Fri, 24 Oct 2008 08:36:53 -0700 (PDT)
Message-ID: <873507.27968.qm@web56304.mail.re3.yahoo.com>
Reply-To: ppak_98@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web56304.mail.re3.yahoo.com ([216.252.110.228]:34794 "HELO
	web56304.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752776AbYJXPnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 11:43:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am programming a server using the epoll interface and have the receive portion of the server working fine, but for some reason as I implement the send portion, I noticed a few things that seem like strange behaviors in the implementation of epoll in the kernel.

I'm running Opensuse 11 and it has a 2.6.25 kernel.

The behavior that I can seeing is when I do a full read on an edge triggered fd, for some reason, it seems to be triggering an epollout events after each loop of the read events on a socket. (before I've done any writes at all to the socket)

This is very strange behavior as I would expect that the epollout event would only be triggered if I did a write and the socket recieved an ack which cleared out the send buffer.

The documentation on epollout is really sparse, so any help at all from the list would be very much appreciated.

I was hoping someone more knowledgeable on the subject here might be able to help explain the epollout behavior and whether or not the extra events are normal and if so, what is the traditional way to handle these extra events in an edge triggered scenario.

Thanks!

Paul


      
