From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: Re: NETLINK: Failed to browse: Invalid argument from avahi-daemon in
 F14 since 2.6.37-git8
Date: Mon, 17 Jan 2011 22:23:18 +0100
Message-ID: <AANLkTikF4HtXzvyiST72t4XE14sjCX-27CLLWvsF8D5o@mail.gmail.com>
References: <AANLkTinHOFwPCwJNCy9cFMCf+_VNb-7YFk-3VJFXoaoZ@mail.gmail.com>
	<20110117083208.GA7569@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110117083208.GA7569@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2011 at 9:32 AM, Jarek Poplawski <jarkao2@gmail.com> wr=
ote:
> On 2011-01-15 19:34, Alessandro Suardi wrote:
>> /var/log/messages says:
>>
>> Jan 13 12:42:02 duff avahi-daemon[2771]: Found user 'avahi' (UID 70)
>> and group 'avahi' (GID 70).
>> Jan 13 12:42:02 duff avahi-daemon[2771]: Successfully dropped root p=
rivileges.
>> Jan 13 12:42:02 duff avahi-daemon[2771]: avahi-daemon 0.6.27 startin=
g up.
>> Jan 13 12:42:02 duff avahi-daemon[2771]: Successfully called chroot(=
).
>> Jan 13 12:42:02 duff avahi-daemon[2771]: Successfully dropped remain=
ing capabilities.
>> Jan 13 12:42:02 duff avahi-daemon[2771]: Loading service file /servi=
ces/ssh.service.
>> Jan 13 12:42:02 duff avahi-daemon[2771]: Loading service file /servi=
ces/udisks.service.
>> Jan 13 12:42:02 duff avahi-daemon[2771]: NETLINK: Failed to browse: =
Invalid argument
>> Jan 13 12:42:23 duff acpid: starting up with netlink and the input l=
ayer
>>
>>
>> Happens both at boot and after boot if restarting avahi-daemon servi=
ce,
>> =A0and there is a 10-15" wait before the service start script prints=
 a [FAILED]
>> =A0red tag; avahi-daemon process does start up anyways.
>>
>> -git7 is the latest "good" kernel
>> -git8, -git9, -git11, -git13 have been reproducing the issue
>>
>>
>> thanks, ciao,
>
> Seems to be resolved in this thread:
>
> http://www.spinics.net/lists/netdev/msg152762.html

Thanks Jarek - filed Fedora bug 670316 for this one.

https://bugzilla.redhat.com/show_bug.cgi?id=3D670316

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
