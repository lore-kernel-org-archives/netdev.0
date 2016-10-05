From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed, 5 Oct 2016 19:23:19 +0200
Message-ID: <20161005192319.713d92e1@griffin>
References: <cover.1475672568.git.jbenc@redhat.com>
        <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
        <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754187AbcJERX0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 13:23:26 -0400
In-Reply-To: <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 5 Oct 2016 17:18:08 +0300, Eyal Birger wrote:
> I think at this point, 'eth' may point to a freed packet.

It may but how does that matter? eth is not used beyond that point.

 Jiri
