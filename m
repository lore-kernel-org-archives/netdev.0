From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: new link failing on duplicate names in different namespaces
Date: Thu, 26 Feb 2015 10:14:03 +0100
Message-ID: <54EEE3DB.4040900@6wind.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>	<54EDF7BB.2060809@6wind.com>	<8761apubru.fsf@x220.int.ebiederm.org>	<CAHA+R7NA6UpC2cy7T14YAxW1gzVi=97yO23pWkkvj1DbV6sTdA@mail.gmail.com> <CAHA+R7Ocu7ig4NL+rrNq3szFBqKVRSSXhPiZDHP4tEzL6OSFzQ@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:36018 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbbBZJOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 04:14:07 -0500
Received: by wghk14 with SMTP id k14so8766805wgh.3
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 01:14:06 -0800 (PST)
In-Reply-To: <CAHA+R7Ocu7ig4NL+rrNq3szFBqKVRSSXhPiZDHP4tEzL6OSFzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/02/2015 06:56, Cong Wang a =E9crit :
> On Wed, Feb 25, 2015 at 9:29 PM, Cong Wang <cwang@twopensource.com> w=
rote:
[snip]
>
> Please give the attached patch a try.
>
It's hard to comment a patch which is sent in attachment
(see=20
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Doc=
umentation/SubmittingPatches#n333).

+				err =3D rtnl_group_changelink(skb, dest_net,
It should probably be something like 'link_net ? : dest_net' instead of
dest_net.

I also don't understand why you need two label ('out' and 'err'). I thi=
nk one is=20
enough (link_net is initialized to NULL for this purpose).
And why not keeping the same name as before, ie 'out'? It will minimize=
 the
patch.
