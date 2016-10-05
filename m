From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed, 5 Oct 2016 21:07:09 +0200
Message-ID: <20161005210709.79732b27@griffin>
References: <cover.1475672568.git.jbenc@redhat.com>
        <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
        <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com>
        <20161005192319.713d92e1@griffin>
        <CAHsH6GvO=F38jXo18=3n1+w+sojRtRcLgbdE9PrGbGyB4vmoEA@mail.gmail.com>
        <20161005184426.GQ25403@egarver>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eyal Birger <eyal.birger@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        pravin shelar <pshelar@ovn.org>
To: Eric Garver <e@erig.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37168 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752617AbcJETHT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 15:07:19 -0400
In-Reply-To: <20161005184426.GQ25403@egarver>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Oct 2016 14:44:26 -0400, Eric Garver wrote:
> On Wed, Oct 05, 2016 at 08:31:52PM +0300, Eyal Birger wrote:
> > Just seemed less future safe to keep a pointer to an old packet lying around.
> 
> I agree. Alternatively refresh the eth pointer.

Sorry guys, that just doesn't make sense. Everyone should know that
reloading of skb pointer means the former pointers to its data may
become invalid. Please point me to any place in the kernel where we
reload the data pointer "just because" even when not used.

 Jiri
