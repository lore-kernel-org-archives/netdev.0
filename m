From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Fri, 8 Aug 2003 17:01:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808170130.578ff441.davem@redhat.com>
References: <200307141045.40999.nf@hipac.org>
	<1058328537.1797.24.camel@jzny.localdomain>
	<3F16A0E5.1080007@hipac.org>
	<1059934468.1103.41.camel@jzny.localdomain>
	<3F2E5CD6.4030500@hipac.org>
	<1060012260.1103.380.camel@jzny.localdomain>
	<3F302E04.1090503@hipac.org>
	<1060286331.1025.73.camel@jzny.localdomain>
	<20030807130502.4af9c815.davem@redhat.com>
	<1060379500.1723.214.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nf@hipac.org, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060379500.1723.214.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 08 Aug 2003 17:51:40 -0400
jamal <hadi@cyberus.ca> wrote:

> Its easy to use hashes when you know that you need to
> find example ip src/dst.

Jenkins is rather agnostic about the input bits, that's
what makes it so powerful.  It performs about as well
for random input as it does for input which has various
patterns.

Wait, are you saying the input key size can change?  Yes,
that's an interesting problem.

But for things where you always want some 96-bit key,
Jenkins is probably best.
