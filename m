From: "Angelo Dell'Aera" <buffer@olografix.org>
Subject: Re: [PATCH] (1/3) tcp - choose congestion algorithm at
 initialization
Date: Mon, 4 Oct 2004 14:42:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004144232.2bfa5a9e.buffer@olografix.org>
References: <20040927111834.48c7baab@zqx3.pdx.osdl.net>
	<20040927121610.68f942a4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040927121610.68f942a4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Mon, 27 Sep 2004 12:16:10 -0700
"David S. Miller" <davem@redhat.com> wrote:

>> The choice of congestion algorithm needs to be made when connection
>> is setup to avoid problems when the sysctl values change later and the
>> necessary data hasn't been collected.

>Looks great, applied.

I completely agree with you. Really a cool work. Just a proposal now. If 
the choice is made when the connection is established we do not need a 
struct for every supported congestion control algorithm in the struct 
tcp_opt any more. We could use for example a generic void * and then refer 
it properly after Stephen's controls such as tcp_is_vegas(), tcp_is_bic(),
etc. This should slim the struct tcp_opt because if a connection is using
Westwood its tcpbic and vegas structs will never be used. Moreover, I think
it would make the code more readable. 

Regards.

- --

Angelo Dell'Aera 'buffer' 
Antifork Research, Inc.	  	http://buffer.antifork.org
Metro Olografix

PGP information in e-mail header


-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFBYUU4pONIzxnBXKIRArT5AJ0Ztak7xFH9DIEd24kRxCvMMxHrBACghKmE
e0CHh6gMpJaW02Y5HVA6u78=
=av9u
-----END PGP SIGNATURE-----
