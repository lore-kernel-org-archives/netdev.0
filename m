From: Alberto Manuel Brandao Simoes <albie@alfarrabio.di.uminho.pt>
Subject: Re: Fw: [Bugme-new] [Bug 3527] New: ssh does not work with 2.6.9rc3
Date: Fri, 08 Oct 2004 21:01:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4166F224.4020801@alfarrabio.di.uminho.pt>
References: <20041008104801.0dd96536.akpm@osdl.org> <20041008181036.GC19714@rei.reeler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041008181036.GC19714@rei.reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Confirmed: there are more commands not working with this kernel (and=20
some which does not use network at all).

[ambs@eremita ambs]$ man man
Error executing formatting or display command.
System command (cd /usr/man && (echo ".pl 1100i"; /bin/gunzip -c=20
'/usr/man/man1/man.1.gz'; echo ".\\\""; echo ".pl \n(nlu+10") |=20
/usr/bin/gtbl | /usr/bin/nroff -S -mandoc | /usr/bin/less -is) exited=20
with status 256.
No manual entry for man
[ambs@eremita ambs]$

And, yes, this works with 2.6.7 :)
Cheers
Alberto

Thomas Graf wrote:
>> With this kernel, the sis ethernet bug is fixed (well, at least I can =
do a ping
>>-f without losing packets), SATA works but... wonder... ssh doesn't.
>>
>>If I have a public key on other machine without passphrase, it works.
>>If not....
>=20
>=20
> Could you provide your .config and a dump of the network
> traffic a few seconds before, during and after the ssh session?
> (tcpdump -s -w ...)
>=20
>=20
>>Now, that file really doesn't exist. But it isn't needed with the old k=
ernel.
>>So, what 2.6.9 rc 3 has that 2.6.7 don't?
>=20
>=20
> I have the feeling that the bug is related to the calculation of
> some networking related threshold resultung in wrong values right
> after booting time.

--=20
Alberto Sim=F5es

Much as I hate to say it, the Computer Science view of language design
has gotten too inbred in recent years. The Computer Scientists should
pay more attention to the Linguists, who have a much better handle on
how people prefer to communicate.
             --Larry Wall
