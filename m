From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: RE: [RFT] BIC TCP delayed ack compensation
Date: Wed, 23 Feb 2005 13:37:35 -0500
Message-ID: <200502231835.j1NIZX2T020606@uni07mr.unity.ncsu.edu>
References: <052Q0TU11@server5.heliogroup.fr>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'Alexey Kuznetsov'" <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        "'David S. Miller'" <davem@davemloft.net>
To: "'Hubert Tonneau'" <hubert.tonneau@fullpliant.org>,
        "'Stephen Hemminger'" <shemminger@osdl.org>,
        "'cliff white'" <cliffw@osdl.org>
In-Reply-To: <052Q0TU11@server5.heliogroup.fr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Hubert Tonneau [mailto:hubert.tonneau@fullpliant.org]
> Sent: Tuesday, February 22, 2005 5:23 PM
> 2.6.9 to 100 Mbps connected MacOSX: 15 seconds (for roughly 100 MB
> or data)
> 2.6.9 to gigabit connected MacOSX: 5 seconds
> 2.6.10-ac11 to 100 Mbps connected MacOSX: 325 seconds
> 2.6.10-ac11 to gigabit connected MacOSX: 5 seconds
> 2.6.10-ac11+BIC to 100 Mbps connected MacOSX: 620 seconds
> 2.6.10-ac11+BIC to gigabit connected MacOSX: 5 seconds

Another way to test whether this is related to the os or bic
implementation is to test it with our bic patch 1.1. + Linux 2.4. It
will tell whether the original implementation of BIC has something to
do with the performance with respect to MacOS. 
