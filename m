From: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: IP_MULTICAST_IF getsockopt man part
Date: Wed, 9 May 2012 11:34:28 +0200
Message-ID: <20120509093428.GB1696@minipsycho.brq.redhat.com>
References: <20120504090013.GA2362@minipsycho>
 <CAKgNAkgBz_dRV97JVV1Np0YuEd0EVqoLPZkajiE_KJ2Lk20YRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAKgNAkgBz_dRV97JVV1Np0YuEd0EVqoLPZkajiE_KJ2Lk20YRA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Sat, May 05, 2012 at 01:57:35PM CEST, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>On Fri, May 4, 2012 at 9:00 PM, Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> Hi.
>>
>> <quote>
>> IP_MULTICAST_IF (since Linux 1.2)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Set the local device for =
a multicast socket.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Argument is an ip_mreqn o=
r ip_mreq structure
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0similar to IP_ADD_MEMBERS=
HIP.
>> </quote>
>>
>> That is not true. Setsockopt recognizes only ip_mreqn and in_addr. I
>> made patch which makes it recognize ip_mreq as well. So that would b=
e
>> probably ok.
>> http://patchwork.ozlabs.org/patch/156815/
>>
>> On the other hand, getsockopt works only with in_addr. That I think =
is
>> good behaviour but manpages here needs to be corrected in this way (=
read
>> part needs to be added here)
>
>Jirka,
>
>I'm having trouble to understand what you mean. Perhaps it would be
>simplest if you showed your proposed replacement text for the text
>quoted above.

<orig>
IP_MULTICAST_IF (since Linux 1.2)
Set the local device for a multicast socket. Argument is an ip_mreqn
or ip_mreq structure similar to IP_ADD_MEMBERSHIP.
</orig>
<new>
IP_MULTICAST_IF (since Linux 1.2)
Set or read the local device for a multicast socket.
Argument for set is an ip_mreqn or ip_mreq or addr_in structure.
Argument for read is an addr_in structure.
</new>


Jirka



>
>Thanks,
>
>Michael
>
>
>
>--=20
>Michael Kerrisk
>Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
>Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
