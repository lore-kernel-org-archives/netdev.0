From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: IP More Fragements bit problem.
Date: Mon, 14 Feb 2005 09:29:24 +0100
Message-ID: <200502140929.24379.vincent.roqueta@ext.bull.net>
References: <200502111708.16024.vincent.roqueta@ext.bull.net> <420CFD1F.2060701@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <420CFD1F.2060701@us.ibm.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Le vendredi 11 F=E9vrier 2005 19:44, vous avez =E9crit=A0:
> Vincent Roqueta wrote:
> > On kernel 2.6.10rc2 and laters (last tested is 2.6.11-rc3) we have:
> >
> > A + MF
> > B + MF
> > C + MF
> > D + MF
> >
> > That cause AIX waiting for the last packet with out sending ack
> > So Linux suppose  AIX didn't receive all, and re send all packets.
> > So AIX is receiving that:
> > A + MF
> > B + MF
> > C + MF
> > D + MF
> > *DELAY *
>
> Silly question, but are you absolutely sure that the original wasn't
> actually ABCDE?
No, we are not sure. It is possible we lack the last fragement witch is n=
ot=20
marked with the MF bit.

Vincent ROQUETA
