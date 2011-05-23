From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [v3 00/39] faster tree-based sysctl implementation
Date: Mon, 23 May 2011 08:59:39 +0300
Message-ID: <BANLkTik0NZSC84-_-j0LyyzSJykH-VxGXw@mail.gmail.com>
References: <BANLkTim7xn8tM4wTyd_m_nwUQg_CUTapeA@mail.gmail.com> <m14o4mavod.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	"David S . Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m14o4mavod.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 23, 2011 at 7:27 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> I will mention a couple of nits I noticed while I was skimming throug=
h
> your patches.
> - There can be multiple proc superblocks and thus multiple inodes
> =C2=A0referring to the same /proc/sys file, if there are multiple pid
> =C2=A0namespaces.


OK. I'll revert the patch that make converts an int counter into an u8
and post an update. I guess this is what you were referring to.
https://github.com/luciang/linux-2.6-new-sysctl/commit/b7a547b8ce7484ae=
22eea34a860f674fcb19c11b


> - I have a hope to move /proc/sys into /proc/<pid>/sys so we don't ha=
ve
> =C2=A0to look at current to determine the namespace we want to displa=
y.
> =C2=A0That would allow the deeply magic sysctl_is_seen check to be re=
moved
> =C2=A0from proc_sys_compare. =C2=A0That is not your problem, but of a=
n
> =C2=A0explanation why the namespaces are passed through.


OK, I'll go an change things to pass the current namespace as it were
before my changes.


Thank you.
--=20
=C2=A0.
=2E.: Lucian
