From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 3/3 v5] iproute2: add support to print 'linkdown'
 nexthop flag
Date: Thu, 18 Jun 2015 09:00:17 -0700
Message-ID: <CAE4R7bC24-A-XsHjjSJQerwDmW5E0MvEmhZEpUfwsiiVma7acA@mail.gmail.com>
References: <1434640932-2681-1-git-send-email-gospo@cumulusnetworks.com>
 <1434640932-2681-4-git-send-email-gospo@cumulusnetworks.com>
 <CAE4R7bDHTCEpqFZYYfCwc=_Wxh6-1BkGuyj04=deGHCHMC--+g@mail.gmail.com> <20150618155659.GN588@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:34600 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932605AbbFRQAi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 12:00:38 -0400
Received: by obbsn1 with SMTP id sn1so57006111obb.1
        for <netdev@vger.kernel.org>; Thu, 18 Jun 2015 09:00:38 -0700 (PDT)
In-Reply-To: <20150618155659.GN588@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 18, 2015 at 8:57 AM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> On Thu, Jun 18, 2015 at 08:43:08AM -0700, Scott Feldman wrote:
>> On Thu, Jun 18, 2015 at 8:22 AM, Andy Gospodarek
>> <gospo@cumulusnetworks.com> wrote:
>> > Signed-off-by: Andy Gospodaerk <gospo@cumulusnetworks.com>
>> > Signed-off-by: Dinesh Dutt <ddutt@cumulusnetworks.com>
>> >
>> > ---
>> >  ip/iproute.c | 4 ++++
>> >  1 file changed, 4 insertions(+)
>> >
>> > diff --git a/ip/iproute.c b/ip/iproute.c
>> > index 3795baf..3369c49 100644
>> > --- a/ip/iproute.c
>> > +++ b/ip/iproute.c
>> > @@ -451,6 +451,8 @@ int print_route(const struct sockaddr_nl *who,=
 struct nlmsghdr *n, void *arg)
>> >                 fprintf(fp, "offload ");
>> >         if (r->rtm_flags & RTM_F_NOTIFY)
>> >                 fprintf(fp, "notify ");
>> > +       if (r->rtm_flags & RTNH_F_LINKDOWN)
>> > +               fprintf(fp, "linkdown ");
>>
>>
>> iproute.c: In function =E2=80=98print_route=E2=80=99:
>> iproute.c:454:21: error: =E2=80=98RTNH_F_LINKDOWN=E2=80=99 undeclare=
d (first use in
>> this function)
>> iproute.c:454:21: note: each undeclared identifier is reported only
>> once for each function it appears in
>
> Yes, you need to pull that from the patches above into your iproute2
> sources.  Stephen regularly tells people not to pose uapi updates, so=
 I
> did not.

Ok, thanks.
