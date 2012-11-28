From: David Shwatrz <dshwatrz@gmail.com>
Subject: Move an interface to init_ne
Date: Wed, 28 Nov 2012 16:39:50 +0200
Message-ID: <CAJJAcodehJ3x2ZjOuoaV=KrWHH23013b3O20nqh0E1smFvFpHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:46048 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755319Ab2K1Ojv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 09:39:51 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so13476632oag.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 06:39:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

How to I move an interface back to the original namespace ?
I created three namespaces:

ip netns add namespace1
ip netns add namespace2
ip netns add namespace3

And move eth0 to namespace1:
ip link set  eth0 netns namespace1

How do I return it back to the original, default network namespace ? (init_net)

	
Regards,
DS
