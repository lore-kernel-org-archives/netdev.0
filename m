From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC1323. No timestamping if SYN timestamp = 0. Bug or Feature?
Date: Thu, 23 Oct 2003 01:37:48 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031023013748.0dd168db.davem@redhat.com>
References: <20031022200152.17005.qmail@web13006.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Bartek Wydrowski <b_wydrowski@yahoo.com.au>
In-Reply-To: <20031022200152.17005.qmail@web13006.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


It is impossible to comply to RFC1323 if we allow TSval in the
initial SYN packet to be zero, from RFC1323:

         When TSecr is not valid, its value must be zero.

It is therefore impossible to accept TSval as zero, because
our TSecr echo of that timestamp would be also zero and thus
invalid.

That is why we reject zero timestamps in the initial SYN packet.
