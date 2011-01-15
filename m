From: Alessandro Suardi <alessandro.suardi@gmail.com>
Subject: NETLINK: Failed to browse: Invalid argument from avahi-daemon in F14
 since 2.6.37-git8
Date: Sat, 15 Jan 2011 19:34:41 +0100
Message-ID: <AANLkTinHOFwPCwJNCy9cFMCf+_VNb-7YFk-3VJFXoaoZ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

/var/log/messages says:

Jan 13 12:42:02 duff avahi-daemon[2771]: Found user 'avahi' (UID 70)
and group 'avahi' (GID 70).
Jan 13 12:42:02 duff avahi-daemon[2771]: Successfully dropped root priv=
ileges.
Jan 13 12:42:02 duff avahi-daemon[2771]: avahi-daemon 0.6.27 starting u=
p.
Jan 13 12:42:02 duff avahi-daemon[2771]: Successfully called chroot().
Jan 13 12:42:02 duff avahi-daemon[2771]: Successfully dropped
remaining capabilities.
Jan 13 12:42:02 duff avahi-daemon[2771]: Loading service file
/services/ssh.service.
Jan 13 12:42:02 duff avahi-daemon[2771]: Loading service file
/services/udisks.service.
Jan 13 12:42:02 duff avahi-daemon[2771]: NETLINK: Failed to browse:
Invalid argument
Jan 13 12:42:23 duff acpid: starting up with netlink and the input laye=
r


Happens both at boot and after boot if restarting avahi-daemon service,
 and there is a 10-15" wait before the service start script prints a [F=
AILED]
 red tag; avahi-daemon process does start up anyways.

-git7 is the latest "good" kernel
-git8, -git9, -git11, -git13 have been reproducing the issue


thanks, ciao,

--alessandro

=A0"There's always a siren singing you to shipwreck"

=A0=A0 (Radiohead, "There There")
