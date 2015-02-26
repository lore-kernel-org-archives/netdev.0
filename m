From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: new link failing on duplicate names in different namespaces
Date: Thu, 26 Feb 2015 15:40:33 +0100
Message-ID: <54EF3061.3040504@6wind.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>	<54EDF7BB.2060809@6wind.com> <8761apubru.fsf@x220.int.ebiederm.org>	<CAHA+R7NA6UpC2cy7T14YAxW1gzVi=97yO23pWkkvj1DbV6sTdA@mail.gmail.com>	<CAHA+R7Ocu7ig4NL+rrNq3szFBqKVRSSXhPiZDHP4tEzL6OSFzQ@mail.gmail.com>	<54EEE3DB.4040900@6wind.com> <87sidsok07.fsf@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <cwang@twopensource.com>,
	Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f53.google.com ([74.125.82.53]:43986 "EHLO
	mail-wg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932166AbbBZOkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 09:40:36 -0500
Received: by wggy19 with SMTP id y19so11364085wgg.10
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 06:40:35 -0800 (PST)
In-Reply-To: <87sidsok07.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/02/2015 14:55, Eric W. Biederman a =C3=A9crit :
[snip]
>
> We can not give the guarantee that a new network device will only liv=
e
> in and have a unique name in a single network namespace until we get
> rid of dev_change_net_namespace in the code.
In fact in case of IFLA_LINK_NETNSID, with Cong's patch, we will first =
check
that the name is unique in link_net and after dev_change_net_namespace(=
) will
check that the name is also unique in the final net, else the command w=
ill fail
(and the device is not created).
