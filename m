From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] kernel: audit: beautify code, for extern function, better
 to check its parameters by itself
Date: Thu, 11 Apr 2013 09:03:40 +0800
Message-ID: <51660BEC.1080901@asianux.com>
References: <5161347B.8090604@asianux.com> <1216477171.11118824.1365615063121.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1216477171.11118824.1365615063121.JavaMail.root@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2013=E5=B9=B404=E6=9C=8811=E6=97=A5 01:31, Eric Paris wrote:
> ----- Original Message -----
>> >=20
>> >   __audit_socketcall is an extern function.
>> >   better to check its parameters by itself.
>> >=20
>> >     also can return error code, when fail (find invalid parameters=
).
>> >     also use macro instead of real hard code number
>> >     also give related comments for it.
>> >=20
>> > Signed-off-by: Chen Gang <gang.chen@asianux.com>
>> > ---
>> >  include/linux/audit.h |   12 ++++++++----
>> >  kernel/auditsc.c      |    9 ++++++---
>> >  net/socket.c          |    6 ++++--
>> >  3 files changed, 18 insertions(+), 9 deletions(-)
>> >=20
>> > diff --git a/include/linux/audit.h b/include/linux/audit.h
>> > @@ -354,7 +358,7 @@ static inline int audit_bprm(struct linux_binp=
rm *bprm)
>> >  {
>> >  	return 0;
>> >  }
>> > -static inline void audit_socketcall(int nargs, unsigned long *arg=
s)
>> > +static inline int audit_socketcall(int nargs, unsigned long *args=
)
>> >  { }
>> >  static inline void audit_fd_pair(int fd1, int fd2)
>> >  { }
> This now returns a value but you forgot to return a value.  Thus this=
 would not even build...   I fixed it up myself.

  thank you very much.


  :-)


--=20
Chen Gang

Asianux Corporation
