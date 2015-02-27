From: Cong Wang <cwang@twopensource.com>
Subject: Re: new link failing on duplicate names in different namespaces
Date: Thu, 26 Feb 2015 16:22:22 -0800
Message-ID: <CAHA+R7Oz-g2BpAgC6V009BY=m9tGa6B7pE1b1iLqCq9814xddw@mail.gmail.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com>
	<8761apubru.fsf@x220.int.ebiederm.org>
	<CAHA+R7NA6UpC2cy7T14YAxW1gzVi=97yO23pWkkvj1DbV6sTdA@mail.gmail.com>
	<CAHA+R7Ocu7ig4NL+rrNq3szFBqKVRSSXhPiZDHP4tEzL6OSFzQ@mail.gmail.com>
	<54EEE3DB.4040900@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:33652 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753970AbbB0AWX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 19:22:23 -0500
Received: by iecar1 with SMTP id ar1so23416430iec.0
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 16:22:23 -0800 (PST)
In-Reply-To: <54EEE3DB.4040900@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 1:14 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 26/02/2015 06:56, Cong Wang a =C3=A9crit :
>>
>> On Wed, Feb 25, 2015 at 9:29 PM, Cong Wang <cwang@twopensource.com> =
wrote:
>
> [snip]
>>
>>
>> Please give the attached patch a try.
>>
> It's hard to comment a patch which is sent in attachment
> (see
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/D=
ocumentation/SubmittingPatches#n333).
>


I knew, it is just not yet ready to submit formally. :)


> +                               err =3D rtnl_group_changelink(skb, de=
st_net,
> It should probably be something like 'link_net ? : dest_net' instead =
of
> dest_net.

I think it should be "link_net ?: net", since it is the source net.
And yes we need to pass the dest_net to this function as well as
do_setlink() too.


>
> I also don't understand why you need two label ('out' and 'err'). I t=
hink
> one is enough (link_net is initialized to NULL for this purpose).
> And why not keeping the same name as before, ie 'out'? It will minimi=
ze the
> patch.

Ah, right, I missed it.

Thanks!
