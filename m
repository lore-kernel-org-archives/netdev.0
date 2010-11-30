From: Laszlo Papp <djszapi@archlinux.us>
Subject: Get the credentials from the socket peer file struct
Date: Tue, 30 Nov 2010 12:13:14 +0200
Message-ID: <AANLkTikP3uqAhULgHp-K871wZq5RQoZVLOCiySj35ZkC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35797 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755059Ab0K3KNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 05:13:15 -0500
Received: by qwb7 with SMTP id 7so5602088qwb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 02:13:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

How can I get the socket peer file struct ?
I would like to implement a new ioctl in my kernelspace code (similar
to SO_PEERCRED), but to get all the credentials.

The file struct of the socket struct has a cred struct members, but
that is for the local file struct, not from the peer file struct.

I tried to grok the documentation, but I do not entirely understand
the 'struct sock' internals.
(http://lxr.free-electrons.com/source/include/net/sock.h?v=2.6.32;a=arm#L144)
SO_PEERCRED just picks 'sk_peercred' struct ucred structure up from
there, but I need a more fine-tuned const struct cred structure in
this special case.

I am not subscrobed for the list, so please add me into the 'CC'
field. Thank you in advance!

Best Regards,
Laszlo Papp
