From: David Dufresne <dufresne@mediafusion.com>
Subject: Can inet_create return -EPROTONOSUPPORT
Date: Fri, 29 Nov 2002 11:04:41 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BA0CFA49.4345%dufresne@mediafusion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

In inet_create, after the lookup for the requested type/protocol pair,
there's a test to see if protocol =3D=3D 0. Why? Because when protocol =3D=
=3D 0,
answer =3D=3D NULL.

Correct me if I'm wrong, please. ;-)
--
David Dufresne, Sys. admin. <dufresne@mediafusion.com>
M=E9diafusion Inc. <http://www.mediafusion.com>
700, rue Wellington Bureau 1200
Montreal (Quebec) H3C 1T4
Tel.(514) 599-5721 Fax.(514) 599-5724
