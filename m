From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [RFC 2/7] NetLabel: core network changes
Date: Thu, 22 Jun 2006 11:05:00 -0400
Message-ID: <200606221105.00331.sgrubb@redhat.com>
References: <20060621194234.979661000@flek.zko.hp.com>
	<20060621200030.880930000@flek.zko.hp.com>
	<20060622.020055.115910616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: jmorris@redhat.com, paul.moore@hp.com, sds@epoch.ncsc.mil,
	redhat-lspp@redhat.com, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov, netdev@vger.kernel.org
Return-path: <redhat-lspp-bounces@redhat.com>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060622.020055.115910616.davem@davemloft.net>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/redhat-lspp>
List-Post: <mailto:redhat-lspp@redhat.com>
List-Help: <mailto:redhat-lspp-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/redhat-lspp>,
	<mailto:redhat-lspp-request@redhat.com?subject=subscribe>
Sender: redhat-lspp-bounces@redhat.com
Errors-To: redhat-lspp-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Thursday 22 June 2006 05:00, David Miller wrote:
> > =A0#define NETLINK_GENERIC=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A01=
6
> > +#define NETLINK_NETLABEL=A0=A0=A0=A0=A017=A0=A0=A0=A0=A0=A0/* Networ=
k packet labeling */
> > =A0
> > =A0#define MAX_LINKS 32=A0=A0=A0=A0=A0=A0=A0=A0=A0
>
> Please use generic netlink.

Since this is a security interface, shouldn't it be its own protocol so t=
hat=20
SE Linux can control commands being sent? Paul's patches do include a net=
link=20
table in security/selinux/nlmsgtab.c. But I do not see any hooks to contr=
ol=20
generic netlink messages. (There seems to be several protocols that SE Li=
nux=20
is not controlling.) I could see that someone in secadm role should be ab=
le=20
to issue these commands, but someone at sysadm or auditadm would not.

If moving this over to generic is a must, then I think SE Linux will have=
 to=20
clip into generic to control its packet flow.

-Steve
