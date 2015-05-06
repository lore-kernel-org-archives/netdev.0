From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: IP_MULTICAST_IF getsockopt man part
Date: Wed, 06 May 2015 12:35:25 +0200
Message-ID: <5549EE6D.3070608@gmail.com>
References: <20120504090013.GA2362@minipsycho> <CAKgNAkgBz_dRV97JVV1Np0YuEd0EVqoLPZkajiE_KJ2Lk20YRA@mail.gmail.com> <20120509093428.GB1696@minipsycho.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Magnus REFTEL <magnus.xm.reftel-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
To: Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120509093428.GB1696-RDzucLLXGGI+74MbWcDs8hcY2uh10dtjAL8bYrjMMd8@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[CC +=3D Magnus, who made a related reported soon after yours.]

Jiri,

On 05/09/2012 11:34 AM, Jiri Pirko wrote:
> Sat, May 05, 2012 at 01:57:35PM CEST, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>> On Fri, May 4, 2012 at 9:00 PM, Jiri Pirko <jpirko-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote=
:
>>> Hi.
>>>
>>> <quote>
>>> IP_MULTICAST_IF (since Linux 1.2)
>>>                      Set the local device for a multicast socket.
>>>                      Argument is an ip_mreqn or ip_mreq structure
>>>                      similar to IP_ADD_MEMBERSHIP.
>>> </quote>
>>>
>>> That is not true. Setsockopt recognizes only ip_mreqn and in_addr. =
I
>>> made patch which makes it recognize ip_mreq as well. So that would =
be
>>> probably ok.
>>> http://patchwork.ozlabs.org/patch/156815/
>>>
>>> On the other hand, getsockopt works only with in_addr. That I think=
 is
>>> good behaviour but manpages here needs to be corrected in this way =
(read
>>> part needs to be added here)
>>
>> Jirka,
>>
>> I'm having trouble to understand what you mean. Perhaps it would be
>> simplest if you showed your proposed replacement text for the text
>> quoted above.
>=20
> <orig>
> IP_MULTICAST_IF (since Linux 1.2)
> Set the local device for a multicast socket. Argument is an ip_mreqn
> or ip_mreq structure similar to IP_ADD_MEMBERSHIP.
> </orig>
> <new>
> IP_MULTICAST_IF (since Linux 1.2)
> Set or read the local device for a multicast socket.
> Argument for set is an ip_mreqn or ip_mreq or addr_in structure.
> Argument for read is an addr_in structure.
> </new>

Long after the fact: I've amended the man page text to read:

       IP_MULTICAST_IF (since Linux 1.2)
              Set  the local device for a multicast socket.  The argu=E2=
=80=90
              ment for setsockopt(2) is an ip_mreqn  or  (since  Linux
              3.5)  ip_mreq structure similar to IP_ADD_MEMBERSHIP, or
              an in_addr  structure.   (The  kernel  determines  which
              structure  is  being  passed based on the size passed in
              optlen.)  For getsockopt(2), the argument is an  in_addr
              structure.

Cheers,

Michael


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
