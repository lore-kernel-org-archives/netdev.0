From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: IP More Fragements bit problem.
Date: Mon, 14 Feb 2005 09:27:38 +0100
Message-ID: <200502140927.38950.vincent.roqueta@ext.bull.net>
References: <200502111708.16024.vincent.roqueta@ext.bull.net> <m1braruf85.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1braruf85.fsf@muc.de>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Le vendredi 11 F=E9vrier 2005 19:24, vous avez =E9crit=A0:
> Vincent Roqueta <vincent.roqueta@ext.bull.net> writes:
> > D + MF
> > *DELAY*
> > A + MF
> > B + MF
> > C + MF
> > D + MF
> > *DELAY*
> > ...
> >
> > After a while AIX destroy first fragments because of the IP fragement=
s
> > life time. Trond Myklebust said me you can do anything for that?
>
> Are you sure? I tested 2.6.10rc3 and it works correctly for
> me with ping. The algorithm in ip_fragment() looks good too
> from visual inspection.
Yes, I am sure testing with NFSv3 over UDP.
I can send you traces seen by AIX.

> And ping uses the same code to fragment as NFS sunrpc
> over UDP.
Ok.
> 19:15:24.100934 averell > trent: (frag 64564:1480@1480+)
> 19:15:24.100938 averell > trent: (frag 64564:1480@2960+)
> 19:15:24.100943 averell > trent: (frag 64564:1480@4440+)
> 19:15:24.100947 averell > trent: (frag 64564:1480@5920+)
> 19:15:24.100951 averell > trent: (frag 64564:1480@7400+)
> 19:15:24.100957 averell > trent: (frag 64564:1128@8880)     <--- No MF.
I don't have that :(

> Also why are you testing NFSv4 over UDP anyways? I thought
> everybody was finally running it over TCP now.
I am not testing NFSv4 over UDP, I am doing NFSv3 tests over UDP to compa=
re=20
performances between NFSv4 and NFSv3, and some interoperablity testing on=
 NFS=20
(v3 and v4). That the last tests that does not work fine.

Vincent
