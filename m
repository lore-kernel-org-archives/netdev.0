From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [GIT PULL] Namespace file descriptors for 2.6.40
Date: Thu, 26 May 2011 00:11:25 +0200
Message-ID: <BANLkTinPTRxmCPhsrqq9fr1veqiNgns_zQ@mail.gmail.com>
References: <m1wrhh3z62.fsf@fess.ebiederm.org> <BANLkTikW4vJbC8kcLSKuemUBbu36SO6hwg@mail.gmail.com>
 <20110525213806.GA4590@mail.hallyn.com> <BANLkTinbw6pZjhMscfXFMArd=XU=VC=+eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: C Anthony Risinger <anthony@xtfx.me>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BANLkTinbw6pZjhMscfXFMArd=XU=VC=+eQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/5/25 C Anthony Risinger <anthony@xtfx.me>:
> On Wed, May 25, 2011 at 4:38 PM, Serge E. Hallyn <serge@hallyn.com> w=
rote:
>> Quoting C Anthony Risinger (anthony@xtfx.me):
[...]
>>> if i understand correctly, mount namespaces (for example), allow on=
e
>>> to build such constructs as "private /tmp" and similar that even
>>> `root` cannot access ... and there are many reasons `root` does not
>>> deserve to completely know/interact with user processes (FUSE makes=
 a
>>> good example ... just because i [user] have SSH access to a machine=
,
>>> why should `root`?)
>> If for instance you have a file open in your private /tmp, then root
>> in another mounts ns can open the file through /proc/$$/fd/N anyway.
>> If it's a directory, he can now traverse the whole fs.
> aaah right :-( ... there's always another way isn't there ... curse
> you Linux for being so flexible! (just kidding baby i love you)
>
> this seems like a more fundamental issue then? =C2=A0or should i not =
expect
> to be able to achieve separation like this? =C2=A0i ask in the contex=
t of
> OS virt via cgroups + namespaces, eg. LXC et al, because i'm about to
> perform a massive overhaul to our crusty sub-2.6.18 infrastructure an=
d
> i've used/followed these technologies for couple years now ... and
> it's starting to feel like "the right time".

You either trust the admin or don't use the machine. There is no third =
way.

Best Regards,
Micha=C5=82 Miros=C5=82aw
