From: Renato Westphal <renatowestphal@gmail.com>
Subject: Re: Move an interface to init_ne
Date: Wed, 28 Nov 2012 13:01:41 -0200
Message-ID: <CAChaegnKhq50mS+T7XrP9A1hYZbT7c+WGD=tUpWtUY2c-ngb7w@mail.gmail.com>
References: <CAJJAcodehJ3x2ZjOuoaV=KrWHH23013b3O20nqh0E1smFvFpHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:35040 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932263Ab2K1PBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 10:01:42 -0500
Received: by mail-vc0-f174.google.com with SMTP id m18so10241999vcm.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 07:01:42 -0800 (PST)
In-Reply-To: <CAJJAcodehJ3x2ZjOuoaV=KrWHH23013b3O20nqh0E1smFvFpHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/11/28 David Shwatrz <dshwatrz@gmail.com>:
> Hello,
>
> How to I move an interface back to the original namespace ?
> I created three namespaces:
>
> ip netns add namespace1
> ip netns add namespace2
> ip netns add namespace3
>
> And move eth0 to namespace1:
> ip link set  eth0 netns namespace1
>
> How do I return it back to the original, default network namespace ? (init_net)

# ip link set eth0 netns 1

The 'netns' argument can be either a netns name or a process ID (pid).
Providing a pid, you'll be moving the interface to the netns of the
given process, which is the initial network namespace for pid = 1 (the
init process).

-- 
Renato Westphal
