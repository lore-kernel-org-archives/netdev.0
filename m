From: "Weber Matthias" <weber@faps.uni-erlangen.de>
Subject: filtering packtes before OS takes care about them
Date: Mon, 28 Feb 2005 17:16:57 +0100
Message-ID: <09766A6E64A068419B362367800D50C0B58A17@moritz.faps.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Content-Class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

i need a possibility to catch IP4 packets (from ethernet devices) before =
OS' netmodules (IP, UDP, TCP, ICMP, ARP, ROUTE, NETFILTER ...) takes care=
 about them and=20
* to delete them from input buffer such that OS' netmodules can't receive=
 them
* to modify packet headers and move packets to interface related output b=
uffers
* to keep them in input buffers such that OS' netmodules can take care ab=
out them.

I would be thankfull for any hint, link or code example.

Bye
Matthias

--

Dipl.-Inf. Matthias Weber
Universit=E4t Erlangen-N=FCrnberg
Lehrstuhl f=FCr Fertigungsautomatisierung und Produktionssystematik Egerl=
andstra=DFe 7-9
91058 Erlangen
Tel. :*49 9131/85-27702
Fax. :*49 9131/302528
www :www.faps.uni-erlangen.de
mailto:weber@faps.uni-erlangen.de
