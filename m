From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 1/4 v2] ipvlan: fix addr hash list corruption
Date: Sat, 28 Mar 2015 19:17:06 +0100
Message-ID: <20150328191706.540f0cfc@griffin>
References: <cover.1427476903.git.jbenc@redhat.com>
	<b5d7fb60399f0a09914ff6dd94787132f40f5c0f.1427476903.git.jbenc@redhat.com>
	<CAF2d9jj-kkmwwJvVe8EjZcnGiy5roEUYh2AqX1Ov3FRNbtXNEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	Dan Williams <dcbw@redhat.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817AbbC1SRL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Mar 2015 14:17:11 -0400
In-Reply-To: <CAF2d9jj-kkmwwJvVe8EjZcnGiy5roEUYh2AqX1Ov3FRNbtXNEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 27 Mar 2015 17:16:49 -0700, Mahesh Bandewar wrote:
> On Fri, Mar 27, 2015 at 10:30 AM, Jiri Benc <jbenc@redhat.com> wrote:
> >  void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync)
> >  {
> > -       hlist_del_rcu(&addr->hlnode);
> > +       hlist_del_init_rcu(&addr->hlnode);
> Though this fixes the current crash problem; the duplicate addition in
> the hash-table is still open. I would still prefer it to be protected
> by hlist_unhashed() check.

It cannot happen but whatever, there's no harm in such check. Just sent
a new version.

 Jiri

-- 
Jiri Benc
