From: Michal Ludvig <mludvig@suse.cz>
Subject: Re: Asynchronous crypto layer.
Date: Sun, 31 Oct 2004 11:46:30 +0100
Message-ID: <4184C286.3000400@suse.cz>
References: <1099030958.4944.148.camel@uganda>	<1099053738.1024.104.camel@jzny.localdomain>	<20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>	<20041030203550.GB6256@gate.ebshome.net>	<20041031010415.4c798a04@zanzibar.2ka.mipt.ru>	<20041030205630.GD6256@gate.ebshome.net>	<20041031012423.74b98698@zanzibar.2ka.mipt.ru>	<1099179687.1041.117.camel@jzny.localdomain> <20041031121308.648e98f9@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, cryptoapi@lists.logix.cz,
        Eugene Surovegin <ebs@ebshome.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041031121308.648e98f9@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Evgeniy Polyakov wrote:
>
>>As he points out (and i am sure he can back it with data ;->), that
>>given the setup cost, packet size, algo and CPU and bus speed, it may
>>not make sense to use the chip at all ;->
>
> Michal has numbers - pure hardware beats soft in a certain setups
> in a fully synchronous schema, let's work SW and HW in parallel.

Yes, I have *some* numbers, but consider that they are for quite
eligible setup - encrypting ~1.5k IPsec packets. I should retry with a
much smaller MTU to see the difference...

I think it won't be the programmer but the system administrator who will
have to correctly set priorities and constraints for different
hardware/software engines for the particular system. With a slow CPU it
may be worth to offload even small blocks to hardware, with a fast one
it may be worth to set HW and SW as equal, etc.

Michal Ludvig
- --
SUSE Labs                    mludvig@suse.cz
(+420) 296.545.373        http://www.suse.cz
Personal homepage http://www.logix.cz/michal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFBhMKDDDolCcRbIhgRAqhBAKCCYwol3N3pd69yBI1HyEEFH0diOACeOqw6
2yCxYNf91eEG1Omi8uQ+Un4=
=i1UL
-----END PGP SIGNATURE-----
