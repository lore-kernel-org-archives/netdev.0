From: Ani Sinha <ani@aristanetworks.com>
Subject: sendmsg() and vlan tags
Date: Fri, 26 Jul 2013 14:30:55 -0700
Message-ID: <CAOxq_8Ni_WszNj0RW++2jdmLwBxbQCJSSC-AS1Ux5TgMEpd2iA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:37065 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933669Ab3GZVbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:31:16 -0400
Received: by mail-oa0-f46.google.com with SMTP id h1so8555384oag.5
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 14:31:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

We know that (since Linux 3.0) on raw sockets, the recvmsg() api
returns the vlan tag information of the packet in the packet aux data.
I looked at the kernel code and it seems on the TX side, in sendmsg(),
we do not accept the vlan tag data from userland for a raw packet. So
if the userland sends a raw packet using sendmsg() with vlan tag
information in aux data, it will be discarded.

Is my analysis correct?

Cheers,
Ani
