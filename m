From: Andreas Schwab <schwab@suse.de>
Subject: Re: Bad UDP checksum with 82540EM
Date: Mon, 09 Feb 2004 01:50:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <jey8rdcbyv.fsf@sykes.suse.de>
References: <101E0EB68A545748974019DC227C554007CBDD@orsmsx406.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "Andi Kleen" <ak@suse.de>, <jonmason@us.ibm.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "cramerj" <cramerj@intel.com>
In-Reply-To: <101E0EB68A545748974019DC227C554007CBDD@orsmsx406.jf.intel.com> (cramerj@intel.com's
 message of "Sun, 8 Feb 2004 15:22:29 -0800")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"cramerj" <cramerj@intel.com> writes:

> Just for clarification...how are you determining a bad checksum?  Are
> you using tcpdump/ethereal on those test machines (that you're
> transmitting from), or are you capturing packets on the wire (from some
> other system receiving the packets).

Actually both.  I have first noticed the issue because my DHCP clients
didn't accept the answers from the server.

> If the former, then please see the following thread.
>
> http://marc.theaimsgroup.com/?t=3D107422099800006&r=3D1&w=3D2
>
> Is this perhaps the issue you're seeing?

I just double checked, the packets are really going out with a bad
checksum.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
