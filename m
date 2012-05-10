From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 07/14] batman-adv: split neigh_new
	function into generic and batman iv specific parts
Date: Thu, 10 May 2012 09:34:25 +0200
Message-ID: <9033916.UuGU18BIPo@bentobox>
References: <1336561976-16088-1-git-send-email-ordex@autistici.org>
	<1336561976-16088-8-git-send-email-ordex@autistici.org>
	<20120509.204111.1931607501484626500.davem@davemloft.net>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart5414075.1lfkItC5uf";
	micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lindner_marek-LWAfsSFWpa4@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20120509.204111.1931607501484626500.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org


--nextPart5414075.1lfkItC5uf
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Wednesday, May 09, 2012 08:41:11 PM David Miller wrote:
[...]
> The namespace pollution of the batman-adv code needs to improve,
> and I'm putting my foot down starting with this change.
> 
> If you have a static function which is therefore private to a
> source file, name it whatever you want.
> 
> But once it gets exported out of that file, you have to give it
> an appropriate name.  Probably with a "batman_adv_" prefix or
> similar.

I aggree, but would like to like to have a shorter prefix batadv_. I know that 
you said "or similar" but there are still some developers that fear your 
response to a patch that only adds the prefix batadv_ instead of the longer 
version.

Could you please approve or disapprove this proposal.

Thanks,
	Sven
--nextPart5414075.1lfkItC5uf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPq2+BAAoJEF2HCgfBJntGbi0P/2+K2xVjmo43E0DtdGSknih/
4Somg6ilKZnV60xfJkvoHMorZlbJsVk+ahrcz4gcF74W/05uire65cxzENGHJ4X4
5/w+UdL/X+/+VfU8naVqI8rBcPJukPNC6y+BFW4J41mFm398cw8D3iTZhawEmI9V
QyBBvezPgyjuOQH7mv1VxQ2j7s5WZZORzZWfKLZTI7Xm2qVMiDqXNulYitfW3+Ul
8K+u5oT7oRYglgZqLlcLPBJqCGxHwDff+EikQSMalfcoqXhp7wXF+bVkUkZ+Ab9Y
oNNUK8LvCB+IiP7Mp4Z4qg+HgVgSq6sqhC3oSaTLE7vJgqEnbwuEQZ01JRHbx0mE
GKQ13eFW37gLa920Qnvmv7XVX1NBLRRqrIIrqcr0nvowDALWCZsRNRjRMFiS5QAK
MBKLFa5Ef+nPV+CORwibZfudIXnfl5yQIQMDf3+kfPmdXHsHHCWZVZRj+6yHjOGh
eHIsBpnPQVMDSVsyR6EWfdCXoE8h+50VEXtBxxPzkt3Y9yxPmlGP/RjEudfIrIHS
RLs6mW3ErUKUq8IS09SXOT8ejJlORH95mVk3aAosxiYHSaBh5nR7sPFRqvhev5SD
U9/+3msaaKmRD73AJPJPtFfQldCqY5lwlNMJmZqSRdgteh4qVRwqwsqwARxO6HpM
cJQctc/3CFSyXtMIZ6xM
=xC8U
-----END PGP SIGNATURE-----

--nextPart5414075.1lfkItC5uf--
