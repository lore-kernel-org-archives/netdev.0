From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check
Date: Fri, 10 Jun 2011 17:49:27 +0800
Message-ID: <BANLkTimHi7V3YwbPepLyW7=pTS7hQVxEBQ@mail.gmail.com>
References: <m11uzcidvq.fsf_-_@fess.ebiederm.org> <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
 <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com> <20110605.141446.1838641439880246155.davem@davemloft.net>
 <20110610083539.GB17568@minipsycho.redhat.com> <BANLkTinqikKoeW6mbjMV9nPii0Nzp4vSdQ@mail.gmail.com>
 <20110610093413.GC17568@minipsycho.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, pratnakarlx@gmail.com,
	ebiederm@xmission.com, shemminger@linux-foundation.org,
	greearb@candelatech.com, nicolas.2p.debian@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39037 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866Ab1FJJts convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 05:49:48 -0400
Received: by bwz15 with SMTP id 15so2040364bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 02:49:47 -0700 (PDT)
In-Reply-To: <20110610093413.GC17568@minipsycho.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 10, 2011 at 5:34 PM, Jiri Pirko <jpirko@redhat.com> wrote:
> Fri, Jun 10, 2011 at 11:26:06AM CEST, xiaosuo@gmail.com wrote:
>>On Fri, Jun 10, 2011 at 4:35 PM, Jiri Pirko <jpirko@redhat.com> wrote=
:
>>> +
>>> +/* Should be used only to revert vlan_reorder_header action */
>>> +static struct sk_buff *vlan_unreorder_header(struct sk_buff *skb)
>>> +{
>>> + =A0 =A0 =A0 unsigned char *mac_header;
>>> + =A0 =A0 =A0 struct vlan_ethhdr *veth;
>>> +
>>> + =A0 =A0 =A0 if (skb_cow(skb, skb_headroom(skb)) < 0)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>>
>>I think we need to make sure if there is enough headroom for this
>>header expansion.
>
> Well the header expansion was previously there so there should be pla=
ce
> there in all cases, or am I wrong?

=46or hw-accel-vlan-rx, is the headroom for this header expansion
reserved? I don't think so. Thanks.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
