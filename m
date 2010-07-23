From: Stuart Sheldon <stu@actusa.net>
Subject: Re: IPv6 Anycast?
Date: Thu, 22 Jul 2010 21:30:12 -0700
Message-ID: <4C491AD4.9070103@actusa.net>
References: <4C48B90B.60304@actusa.net> <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stuart Sheldon <stu@actusa.net>
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from internal.actusa.net ([208.83.100.16]:42178 "EHLO
	internal.actusa.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751803Ab0GWEaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 00:30:22 -0400
In-Reply-To: <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Yea, I'm sure...

We use Linux for routers as well as servers and workstations. Since I
sent this I've discovered that by default, when a Linux system has IPv6
forwarding turned on, it adds the <network>::/64 anycast router
addresses on all the interfaces (as per rfc 2526).

What I'm actually looking to do is (change / add) other addresses the to
anycast6 list to work in an existing configuration that does not use the
rfc 2526 anycast router address.

Is there a command line method of setting up these anycast addresses?

Thanks,

Stu Sheldon
ACT USA


On 07/22/2010 08:57 PM, Mikael Abrahamsson wrote:
> On Thu, 22 Jul 2010, Stuart Sheldon wrote:
> 
>> -----BEGIN PGP SIGNED MESSAGE-----
>> Hash: SHA256
>>
>> Is IPv6 Anycast supported? And if so, how do I setup the Anycast
>> addresses?
> 
> Are you sure that's what you're looking for?
> 
> <http://en.wikipedia.org/wiki/Anycast>
> 
> Because that's more a function of routing protocol/network, than
> anything really related to "netdev".
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBCAAGBQJMSRrUAAoJEFKVLITDJSGSVnMP+wRF0jrC8RJn+C0EBlNl4uoW
qzEjGgrj7fqf9GOa5XWwVkoWHsZNyRZxJgNo73sS/s0PDwsFaZ11PWPqCSE1wafO
JkfKjhz3b7KOUjUNyYcvqzR45reRpoDUWVXpVYtqfzvCWvf6xdimatHFcKc3f14W
vX3rUG9BaWMuc74u/BZgKxpLXqTdXCwVIEXETSFGy63AdQSN9SIRlmgd6a60FGwJ
Cyr60Os8zAUDooQ++xwLB/ito6NdT7xAho2JRjejC0eblXYYT3bQU+kkS0qeHhYY
ucMuz18W6WswRM/wTnHzG7DvdRQNWMyvDvzR+qSQiAY6WMmwJ7qWfy1Ikj8l0QPe
5g0qI9Et/jOLzcwIrH2BAif8rBSpOHjqhXxhFNCtXyPsmIulZu4UzV1GbqV60Vp4
fixW4hgPDoqlwvfnojEZSVGxEy67GApokA7+TRY+sHQPvAhxA7b7WrT7liYgcW2B
4gTeaSbrvj6pw3ndYfrjOtbqlH29rU2RXi1MAhOq2fSrtIijMGZdKw6t5YbT5xik
qm3PRLYCzFocWP2sykjTds6VuHzhxm7+sqNe8p+0pyUoUYG9lNVyviMNHn0uz9L9
PDi8iIyDVHvEw6AHzmnmYc4RAz4Q/w/VxMY8jwjYurUnEyt9rtjMXsfv5rb2qkcB
cuyzbrEkx/49bRL+HZDx
=K4wA
-----END PGP SIGNATURE-----
