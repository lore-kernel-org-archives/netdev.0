From: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 1/2] connector: add cgroup release event report to proc connector
Date: Thu, 11 Jun 2015 18:28:59 +0300
Message-ID: <1059221434036539@web13o.yandex.ru>
References: <1432678051-4372-1-git-send-email-dimitri.j.ledkov@intel.com>
	 <5565A8F9.8040601@huawei.com> <CAK7xexkFm_BZ9sdB3VAZ-WGiikBeAQfaimXjggEtac+M2diV-g@mail.gmail.com>
	 <55668BE9.1090100@huawei.com> <CAK7xexmATyoUsOb5cgHF-Pz91ihQHm47sJoXmi15fk87yBJjNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dimitri John Ledkov <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Zefan Li <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAK7xexmATyoUsOb5cgHF-Pz91ihQHm47sJoXmi15fk87yBJjNw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi

28.05.2015, 11:54, "Dimitri John Ledkov" <dimitri.j.ledkov-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>:

> What you are saying is that we have inefficient notification mechanism
> that hammers everyone's boot time significantly, and no current path
> to resolve it. What can I do get us efficient cgroup release
> notifications soon?
> This patch-set is a no-op if one doesn't subscribe from the userspace
> and has no other side effects that I can trivially see and is very
> similar in-spirit to other notifications that proc-connector
> generates. E.g. /proc/pid/comm is exposed as a file, yet there is proc
> connector notification as well about comm name changes. Maybe Evgeniy
> can chip in, if such a notification would be beneficial to
> proc-connector.

I understand your need in a new notifications related to cgroups,
although I would rather put it into separate module than proc connector - 
I'm pretty sure there will be quite alot of extensions in this module in the future.

But if you do want to extend proc connector module, I'm ok with it, but it should
go via its maintainer.
