From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: SCTP path mtu support needs some ip layer support.
Date: 14 Jan 2003 01:03:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1042498998.2610.8.camel@devil>
References: <Pine.LNX.4.33.0301131417440.1691-100000@dyn9-47-18-98.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, Jon Grimm <jgrimm2@us.ibm.com>, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.33.0301131417440.1691-100000@dyn9-47-18-98.beaverton.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I know this is not what the SCTP spec recommends with IPv4, but what
prevents you from just fragmenting the IP packets at the source and
setting the DF bit on each fragment (assuming you can't just repackage
the data chunks)? This would be equivalent to the IPv6 behaviour and
would keep PMTUD working perfectly.

With IPv6 you don't have a DF bit to control, so you have only two
options. Either use a maximum chunk size smaller than 1280, or fragment
at the source.

Regards,

	MikaL
