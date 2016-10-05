From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed, 5 Oct 2016 14:44:26 -0400
Message-ID: <20161005184426.GQ25403@egarver>
References: <cover.1475672568.git.jbenc@redhat.com>
 <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
 <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com>
 <20161005192319.713d92e1@griffin>
 <CAHsH6GvO=F38jXo18=3n1+w+sojRtRcLgbdE9PrGbGyB4vmoEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Benc <jbenc@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        pravin shelar <pshelar@ovn.org>
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46906 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752265AbcJESo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 14:44:27 -0400
Content-Disposition: inline
In-Reply-To: <CAHsH6GvO=F38jXo18=3n1+w+sojRtRcLgbdE9PrGbGyB4vmoEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 05, 2016 at 08:31:52PM +0300, Eyal Birger wrote:
> On Wed, Oct 5, 2016 at 8:23 PM, Jiri Benc <jbenc@redhat.com> wrote:
> > On Wed, 5 Oct 2016 17:18:08 +0300, Eyal Birger wrote:
> >> I think at this point, 'eth' may point to a freed packet.
> >
> > It may but how does that matter? eth is not used beyond that point.
> 
> Definitely a nit. For sure not critical.
> 
> Just seemed less future safe to keep a pointer to an old packet lying around.

I agree. Alternatively refresh the eth pointer.
