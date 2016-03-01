From: Vincent Bernat <bernat-PWwKhitvBKI@public.gmane.org>
Subject: Re: [PATCH v2] socket.7: Document some BPF-related socket options
Date: Tue, 01 Mar 2016 11:10:43 +0100
Message-ID: <87k2lm7bks.fsf@zoro.exoscale.ch>
References: <1456767399-7533-1-git-send-email-kraigatgoog@gmail.com>
	<56D56901.5070307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Craig Gallek <kraigatgoog-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56D56901.5070307-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (Michael Kerrisk's message of "Tue,
	1 Mar 2016 11:03:45 +0100")
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 =E2=9D=A6  1 mars 2016 11:03 +0100, "Michael Kerrisk (man-pages)" <mtk=
=2Emanpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>=C2=A0:

>           Once   the   SO_LOCK_FILTER  option  has  been  enabled,
>           attempts by an unprivileged process to change or  remove
>           the  filter  attached  to  a  socket,  or to disable the
>           SO_LOCK_FILTER option will fail with the error EPERM.

You should remove "unprivileged". I didn't try to check for permissions
because I was just lazy (and I didn't have a need for it). As root, you
can just recreate another socket.
--=20
Choose a data representation that makes the program simple.
            - The Elements of Programming Style (Kernighan & Plauger)
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
