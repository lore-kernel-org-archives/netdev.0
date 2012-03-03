From: Neal Cardwell <ncardwell@google.com>
Subject: Re: crash in tcp_fragment
Date: Sat, 3 Mar 2012 02:38:01 -0500
Message-ID: <CADVnQykkYXDNsGbNvO6draktbiTVw1s2ArdhSONZo=80cNUAww@mail.gmail.com>
References: <1330311465.2552.23.camel@boudreau>
	<alpine.DEB.2.00.1202280115020.17924@melkinpaasi.cs.helsinki.fi>
	<1330385392.7041.16.camel@boudreau>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: tim@edgecast.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:62296 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab2CCHiC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 02:38:02 -0500
Received: by qaeb19 with SMTP id b19so128951qae.19
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2012 23:38:01 -0800 (PST)
In-Reply-To: <1330385392.7041.16.camel@boudreau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a proposed fix I just posted for this issue:

  http://patchwork.ozlabs.org/patch/144408/

neal

On Mon, Feb 27, 2012 at 6:29 PM, Tim Hartrick <tim@edgecast.com> wrote:
>
> Ilpo,
>
> Thanks for the answers. =A0This gives me some clarity on how to addre=
ss
> the problem.
>
>
> Tim Hartrick
>
> On Tue, 2012-02-28 at 01:18 +0200, Ilpo J=E4rvinen wrote:
>> On Sun, 26 Feb 2012, Tim Hartrick wrote:
>>
>> > =A0 =A0 We have been seeing the crash cited below on a number of o=
ur systems
>> > running kernel version 2.6.34, 2.6.36 and 2.6.38 using a number of
>> > different GigE controllers. =A0I note that commit
>> > 2fceec13375e5d98ef033c6b0ee03943fc460950 introduced a band-aid for=
 the
>> > problem by replacing the BUG_ON() to a WARN(). =A0I have two quest=
ions
>> > related to this.
>> >
>> > 1) Is there a fix for the root cause? =A0Can I get a pointer to th=
e commit
>> > that claims to address the root cause?
>>
>> There have been multiple fixes recently on the counters which this c=
ode
>> depends on, however, nobody has afaict fully analyzed what else thos=
e
>> fixed.
>>
>> > 2) Will disabling GSO/TSO make the problem go away? =A0That is, is
>> > something related to GSO/TSO at the root of the problem?
>>
>> Very likely.
>>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
