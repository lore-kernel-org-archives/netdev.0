From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Mon, 11 Aug 2003 22:40:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811224050.59bc36fe.davem@redhat.com>
References: <200307141045.40999.nf@hipac.org>
	<1058328537.1797.24.camel@jzny.localdomain>
	<3F16A0E5.1080007@hipac.org>
	<1059934468.1103.41.camel@jzny.localdomain>
	<3F2E5CD6.4030500@hipac.org>
	<1060012260.1103.380.camel@jzny.localdomain>
	<3F302E04.1090503@hipac.org>
	<1060286331.1025.73.camel@jzny.localdomain>
	<3F381B3E.6080807@hipac.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Bellion and Thomas Heinz <nf@hipac.org>
In-Reply-To: <3F381B3E.6080807@hipac.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 12 Aug 2003 00:39:58 +0200
Michael Bellion and Thomas Heinz <nf@hipac.org> wrote:

> This is a fundamental issue related to the use of hashes in this
> context. It shows that it is _impossible_ to create a hash which
> meets the requirement of O(1) rules per bucket in the setting
> described above regardless how clever you choose the hash function.
> 
> What do you think about it? Do you agree?

The ipv4 FIB hash tables tackle exactly this problem.  The resulting
worse cast complexity is O(n_bits_in_prefix_mask).

The problem you've described is exactly the same as trying to use
hashing for routing tables.
