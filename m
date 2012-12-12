From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] ip: use rtnelink to manage mroute
Date: Wed, 12 Dec 2012 10:26:17 -0800
Message-ID: <20121212102617.0a3249e4@nehalam.linuxnetplumber.net>
References: <1355304728-4944-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50954 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754143Ab2LLS1h convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 13:27:37 -0500
In-Reply-To: <1355304728-4944-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 10:32:08 +0100
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> mroute was using /proc/net/ip_mr_[vif|cache] to display mroute entrie=
s. Hence,
> only RT_TABLE_DEFAULT was displayed and only IPv4.
> With rtnetlink, it is possible to display all tables for IPv4 and IPv=
6. The output
> format is kept. Also, like before the patch, statistics are displayed=
 when user specify
> the '-s' argument.
>=20
> The patch also adds the support of 'ip monitor mroute', which is now =
possible.
>=20
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---

The functionality is fine, and if you clean it up I will accept it.

Patch does not apply cleanly against current iproute2 git.

Also, it causes several compiler warnings.
ipmonitor.c: In function =E2=80=98accept_msg=E2=80=99:
ipmonitor.c:50:20: warning: format =E2=80=98%d=E2=80=99 expects argumen=
t of type =E2=80=98int=E2=80=99, but argument 3 has type =E2=80=98long =
unsigned int=E2=80=99 [-Wformat]

ipmroute.c: In function =E2=80=98print_mroute=E2=80=99:
ipmroute.c:165:4: warning: format =E2=80=98%lu=E2=80=99 expects argumen=
t of type =E2=80=98long unsigned int=E2=80=99, but argument 4 has type =
=E2=80=98__u64=E2=80=99 [-Wformat]
ipmroute.c:165:4: warning: format =E2=80=98%lu=E2=80=99 expects argumen=
t of type =E2=80=98long unsigned int=E2=80=99, but argument 5 has type =
=E2=80=98__u64=E2=80=99 [-Wformat]
ipmroute.c:168:5: warning: format =E2=80=98%lu=E2=80=99 expects argumen=
t of type =E2=80=98long unsigned int=E2=80=99, but argument 3 has type =
=E2=80=98__u64=E2=80=99 [-Wformat]
