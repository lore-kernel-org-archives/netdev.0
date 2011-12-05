From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] datapath: Fix build breakage on kernel 2.6.40
Date: Mon, 5 Dec 2011 09:32:15 -0800
Message-ID: <CAEP_g=_gQWsobn1me=6KABJTwttQmfuVOpj_tJrr70XCC+5Wwg@mail.gmail.com>
References: <1323052394-12711-1-git-send-email-zwu.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dev@openvswitch.org, stefanha@gmail.com, netdev@vger.kernel.org,
	aliguori@us.ibm.com, ryanh@us.ibm.com
To: Zhi Yong Wu <zwu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43352 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932645Ab1LERch convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 12:32:37 -0500
Received: by iakc1 with SMTP id c1so2365954iak.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 09:32:37 -0800 (PST)
In-Reply-To: <1323052394-12711-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 4, 2011 at 6:33 PM, Zhi Yong Wu <zwu.kernel@gmail.com> wrot=
e:
> Today i played with openvswitch on my workstation with kernel 2.6.40 =
and found that it break when i built. The
> +issue is introduced by commit ceb176fdb72bb7ce90debc66e1eeb1d25823d3=
0a
>
> Below is the error log:
>
> from /home/zwu/work/virt/openvswitch/datapath/linux/genetlink-brcompa=
t.c:10:
> /home/zwu/work/virt/openvswitch/datapath/linux/compat/include/linux/s=
kbuff.h:243:20: error: redefinition of
> +=E2=80=98skb_reset_mac_len=E2=80=99
> include/linux/skbuff.h:1259:20: note: previous definition of =E2=80=98=
skb_reset_mac_len=E2=80=99 was here
> make[5]: *** [/home/zwu/work/virt/openvswitch/datapath/linux/genetlin=
k-brcompat.o] Error 1
> make[4]: *** [_module_/home/zwu/work/virt/openvswitch/datapath/linux]=
 Error 2
> make[4]: Leaving directory `/usr/src/kernels/2.6.40.6-0.fc15.x86_64'
> make[3]: *** [default] Error 2
> make[3]: Leaving directory `/home/zwu/work/virt/openvswitch/datapath/=
linux'
> make[2]: *** [all-recursive] Error 1
> make[2]: Leaving directory `/home/zwu/work/virt/openvswitch/datapath'
> make[1]: *** [all-recursive] Error 1
> make[1]: Leaving directory `/home/zwu/work/virt/openvswitch'
> make: *** [all] Error 2
>
>
> Signed-off-by: Zhi Yong Wu <zwu.kernel@gmail.com>

Applied, thanks.
