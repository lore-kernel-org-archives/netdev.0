From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2] net: Fix unused variable compile warning
Date: Mon, 5 Oct 2015 10:53:57 -0700
Message-ID: <CAHA+R7PTyS=wtowhKZ4osDs_VF=UJvfhw_xkWO3PQZuiFdnTsw@mail.gmail.com>
References: <1443714544-21595-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Ahern <dsahern@gmail.com>,
	David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34140 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498AbbJERx6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:53:58 -0400
Received: by ykdg206 with SMTP id g206so177336090ykd.1
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:53:57 -0700 (PDT)
In-Reply-To: <1443714544-21595-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 1, 2015 at 8:49 AM, David Ahern <dsa@cumulusnetworks.com> w=
rote:
> Eric's net namespace changes in 1b75097dd7a26 leaves net unreferenced=
 if
> CONFIG_IP_VS_IPV6 is not enabled:
>
> ../net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_out=E2=
=80=99:
> ../net/netfilter/ipvs/ip_vs_core.c:1177:14: warning: unused variable =
=E2=80=98net=E2=80=99 [-Wunused-variable]
>
> After the net refactoring there is only 1 user; push the reference to=
 the
> 1 user. While the line length slightly exceeds 80 it seems to be the
> best change.
>
> Fixes: 1b75097dd7a26("ipvs: Pass ipvs into ip_vs_out")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

I saw the same build warning, and this fix looks good to me.

DaveM, can you take this?

Thanks.
