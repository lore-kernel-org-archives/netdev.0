From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Thu, 24 Jul 2003 20:11:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307242011420101.00BC642D@192.168.128.16>
References: <Pine.LNX.4.44.0307241922270.10460-100000@l>
 <200307241836060226.006FACEB@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Bart De Schuymer" <bdschuym@pandora.be>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <200307241836060226.006FACEB@192.168.128.16>
To: "Carlos Velasco" <carlosev@newipnet.com>, "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 18:36 Carlos Velasco wrote:

>>	There are some exceptions for the src IP. Even Linux will
>>not reply if the src IP in incoming probe matches local IP. But
>>may be only Linux preserves the src IP in outgoing probes.

Tested these platforms:

Solaris 8 -> sends src IP address of INTERFACE
Cisco -> sends src IP address of INTERFACE
Windows 2000, XP -> sends src IP address of INTERFACE
Linux 2.6.0-pre1, 2.4.20, 2.4.21 -> sends src IP address of LOOPBACK

Question: =BFWhat would be the implications of applying my patch or simil=
ar to do linux behave like other OS?

>Will open a TAC case tomorrow. I'm interested on testing this in Solaris.

Same tests:

Solaris 8 -> replies the ARP request
Windows 2000, XP -> replies the ARP request
Linux 2.4.21 -> replies the ARP request
Cisco -> NOT replies the ARP request

I will contact Cisco to see why they don't do and if it can be fixed in f=
uture releases.

Regards,
Carlos Velasco
