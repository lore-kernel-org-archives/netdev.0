From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH v3 0/14] some netpoll and netconsole fixes
Date: Fri, 10 Aug 2012 10:13:22 +0800
Message-ID: <1344564802.17296.1.camel@cr0>
References: <1344524426-11588-1-git-send-email-amwang@redhat.com>
	 <20120809.163046.584126910434037730.davem@davemloft.net>
	 <20120809.163616.132379032405824162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53344 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab2HJCN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 22:13:28 -0400
In-Reply-To: <20120809.163616.132379032405824162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-09 at 16:36 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 09 Aug 2012 16:30:46 -0700 (PDT)
>=20
> > From: Cong Wang <amwang@redhat.com>
> > Date: Thu,  9 Aug 2012 23:00:12 +0800
> >=20
> >> V3:
> >> * add more patches
> >> * update patch 7 as David suggested
> >>=20
> >> V2:
> >> * update patch 1/8 as Eric suggested
> >> * drop the bridge patch, add comments instead
> >> * add patch 8/8
> >>=20
> >> This patchset fixes serval problems in netconsole and netpoll.
> >>=20
> >> I ran this patch in my KVM guest with some netpoll test cases,
> >> even covered with some corner cases, everything worked as expected=
=2E
> >=20
> > All applied to 'net', thanks for fixing all of this stuff.
>=20
> Actually, you didn't test the build very well, I'm reverting:
>=20
> In file included from drivers/net/team/team_mode_broadcast.c:17:0:
> include/linux/if_team.h: In function =E2=80=98team_dev_queue_xmit=E2=80=
=99:
> include/linux/if_team.h:107:6: error: dereferencing pointer to incomp=
lete type
> make[3]: *** [drivers/net/team/team_mode_broadcast.o] Error 1
> make[3]: *** Waiting for unfinished jobs....
> In file included from drivers/net/team/team.c:31:0:
> include/linux/if_team.h: In function =E2=80=98team_dev_queue_xmit=E2=80=
=99:
> include/linux/if_team.h:107:6: error: dereferencing pointer to incomp=
lete type
> make[3]: *** [drivers/net/team/team.o] Error 1
> make[2]: *** [drivers/net/team] Error 2
> make[2]: *** Waiting for unfinished jobs....

Oops! Sorry that I forgot to enable CONFIG_NET_TEAM.

Do you want me to send a delta patch or send v4?

Thanks.
