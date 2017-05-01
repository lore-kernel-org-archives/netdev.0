From: carl h <heyen2000@gmail.com>
Subject: Re: How does vlan driver pass vlan info to the h/w ethernet driver
Date: Mon, 1 May 2017 10:20:26 -0400
Message-ID: <CABM+yxkiOpOs5b5MM6MD4woz5R2-4_gf=t=8THXb3p=wuwTtXg@mail.gmail.com>
References: <CABM+yxkwQ1Oiw9p0tehLYyNgh6Qj=+1KKNk4hy35vz00DveyGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35425 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165217AbdEAOU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 10:20:29 -0400
Received: by mail-lf0-f45.google.com with SMTP id 75so60757717lfs.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 07:20:28 -0700 (PDT)
In-Reply-To: <CABM+yxkwQ1Oiw9p0tehLYyNgh6Qj=+1KKNk4hy35vz00DveyGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can't seem to get any response to this.

If there is a better place to get help for this question please let me know=
.

Note: I have already posted the same question in Linux&Users and
StackOverflow without luck either.


On Fri, Apr 28, 2017 at 9:46 AM, carl h <heyen2000@gmail.com> wrote:
> Desperately need info on this.
>
> I'm trying to implement vlans on a target programmatically.
>
> But first I wanted to set up vlans manually to help get a better
> understanding of vlan setup. So I setup a vlan manually on my
> development system (ubuntu) using the vconfig/ifconfig command
> combination, but using the same command combination on the intended
> target doesn't work.
>
> Both systems use the same 8021q driver so the method of informing the
> lower level Ethernet driver of the vlan info should be the same (I
> would think). After looking at the vlan driver source it appears that
> it collects the vlan info and adds the info the sk_buff structure
> which is eventually passed to the ethernet driver, but it's not
> obvious where the vlan magic is suppose to happen (ethernet driver or
> 8021q driver).
>
> I looked at the source for the target system=E2=80=99s ethernet driver an=
d it
> supports an ioctl method of setting up a vlan. But this does not seem
> like the conventional way that Linux sets up a vlan in the ethernet
> driver.
>
> By what mechanism does the vlan driver (8021q.ko) tell the Ethernet
> hardware about a vlan?
>
> Is it a special api call to the ethernet driver to set up a vlan in
> hardware, or should the vlan driver be adding the vlan tags to the
> packet?
>
> Any info on vlan implementation would also be helpful too.
