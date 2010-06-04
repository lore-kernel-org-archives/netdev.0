From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: 200 millisecond timeouts in TCP
Date: Sat, 5 Jun 2010 07:55:41 +0900
Message-ID: <AANLkTinhb-5T2FqJ6jtgCckT4C69ilGLXrdAy4RcacLe@mail.gmail.com>
References: <AANLkTils4KHXwX79cLG6UvVOaDdddMqx-1tyUL3VtLQC@mail.gmail.com>
	<AANLkTilsYS8P2VqATmasXjjdhjPMMZznIHBByXc1i8cU@mail.gmail.com>
	<20100604150202.GA8268@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Novick <novickivan@gmail.com>, netdev@vger.kernel.org
To: Satoru SATOH <satoru.satoh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52501 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754177Ab0FDWzn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 18:55:43 -0400
Received: by vws5 with SMTP id 5so263261vws.19
        for <netdev@vger.kernel.org>; Fri, 04 Jun 2010 15:55:42 -0700 (PDT)
In-Reply-To: <20100604150202.GA8268@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi satoru,

On Sat, Jun 5, 2010 at 12:02 AM, Satoru SATOH <satoru.satoh@gmail.com> =
wrote:
> It's possible to tune the RTO min value (rto_min) per route since
> 2.6.23+. =A0(see also the manual of iproute2, ip(8) )
>
Yeah, I forgot it.  Per route configuration is a nice idea compared
with global sysctls.

Thanks!
Ryousei

> - satoru
>
> On Fri, Jun 04, 2010 at 03:58:57PM +0900, Ryousei Takano wrote:
>> On Fri, Jun 4, 2010 at 7:37 AM, Ivan Novick <novickivan@gmail.com> w=
rote:
>> > Hello,
>> >
>> > Using tcpdump and systemtap I am seeing that sometimes retransmiss=
ion
>> > of data is sent after waiting 200 milliseconds. =A0However sometim=
es
>> > retransmissions happen quicker.
>> >
>> > Is there a specifc event that causes these 200 milisec delays to k=
ick
>> > in? =A0Are those events identifiable in netstat -s output?
>> >
>> > Also do you know if the timeout numbers for TCP are configurable p=
arameters?
>> >
>> The minimum RTO value is fixed to 200 ms. =A0It is useful to make th=
e min/max
>> RTO values tunable. =A0For example, reducing the minimum RTO value i=
s effective
>> for TCP incast problem [1]. =A0Of course, it may occur spurious retr=
ansmissions.
>>
>> [1] Vijay Vasudevan, et al, Safe and Effective Fine-grained TCP Retr=
ansmissions
>> for Datacenter Communication, SIGCOMM2009
>>
>> In Solaris, there are two tunable parameters: tcp_rexmit_interval_mi=
n/max.
>>
>> Do you have plan to introduce sysctl parameters like these to the Li=
nux.
>>
>> Thanks,
>> Ryousei
>
