From: Eyal Birger <eyal.birger@gmail.com>
Subject: Re: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed, 5 Oct 2016 20:31:52 +0300
Message-ID: <CAHsH6GvO=F38jXo18=3n1+w+sojRtRcLgbdE9PrGbGyB4vmoEA@mail.gmail.com>
References: <cover.1475672568.git.jbenc@redhat.com> <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
 <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com> <20161005192319.713d92e1@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33647 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755061AbcJERby (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 13:31:54 -0400
Received: by mail-wm0-f66.google.com with SMTP id p138so25607095wmb.0
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2016 10:31:54 -0700 (PDT)
In-Reply-To: <20161005192319.713d92e1@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 5, 2016 at 8:23 PM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 5 Oct 2016 17:18:08 +0300, Eyal Birger wrote:
>> I think at this point, 'eth' may point to a freed packet.
>
> It may but how does that matter? eth is not used beyond that point.

Definitely a nit. For sure not critical.

Just seemed less future safe to keep a pointer to an old packet lying around.

Eyal.
