From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: [PATCH] e1000: save skb counts in TX to avoid
	cache misses
Date: Thu, 07 Jun 2012 15:02:58 -0700
Message-ID: <4FD12512.1010005@gmail.com>
References: <b838d871c0d507787373061e4edd91a624d62475.1339073391.git.rkagan@parallels.com>
	<4FD11F49.5060805@gmail.com>
	<20120607.144358.1732928576389957779.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2788333783859921421=="
Cc: rkagan@parallels.com, e1000-devel@lists.sourceforge.net, dnelson@redhat.com,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	stable@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20120607.144358.1732928576389957779.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--===============2788333783859921421==
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature";
	boundary="------------enig038063C610A34E6E1F72D3E7"

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig038063C610A34E6E1F72D3E7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 06/07/2012 02:43 PM, David Miller wrote:
> From: Jeff Kirsher <tarbal@gmail.com>
> Date: Thu, 07 Jun 2012 14:38:17 -0700
>
>> Thanks! I have applied the patch to my queue
> Why?
>
> My impression is that this is a patch already in the tree, and it's
> being submitted for -stable but such minor performance hacks are
> absolutely not appropriate for -stable submission.
I did not catch that Roman was trying to get this into stable because
there was no mention of what stable kernels this was applicable back to
(and the fact that it was a performance).

I thought he had found an issue with the previous commits and was
suggesting a fix to the previous patches.

Since he is trying to get this into -stable, disregard my statement
about adding it to my tree.


--------------enig038063C610A34E6E1F72D3E7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJP0SUSAAoJEOVv75VaS+3OSDsP/3oAiEaOuT5bmKZz3LA4kPOL
5jFtTeHccAGz9d2gKVCuN4D+9jHmCj7SslZNRAMncKaEVsoRbo5sMpkucjLBF6xg
nQTRNIMRh/MGSlG2Cw+T4h9Ci+rXmP4FtrJs2At7jE+9j5dFI3OefNoeP68boivt
2RQ1EbjCFYizwTNY+B5V2tOSwIJf/lmAUTAdyYBP7iS9ybVlrHmlQ8Yi7v6sze2P
oNflAJclfniixhlb6WBvN+p5HaQpxtAJZxIGUwPBKBX/5hSn5kJT88dqClPWx8LP
XltYtLHzyOE69Ic/7ngfXfOawCt+SFzt2Wl9vqQ7cWKAG2gCy5B8ki5G4N0GCb2b
vME3sNGL/XRS+64CAoPdbuS+9gSo/ZRQvlDTF2FC5ZsHHmd4jogQQJPyktT11wHg
TsKykz6o0hx0Gi3eF/7XSfqEG2FibKStFYTv53G7s9GmonlO8VjSxVPRTkG7trX+
u+KCFb13KAVp1vhmVMbiQeNlpXkcy9LFp3cJJ30+11lxO26IB6avTtsDFFPRcB5M
PYcvFPcdjNmUP7eb6TsN7KxmTJy8+NWxhlX4H2+nLILXEEhkZsvkkCQdh8L2xzdC
Ko547FeSIYtwIDL+RChfNde7DQ/F9UdEMUH02QDt7svSD0wZH55Dn5mi8ob4lcRW
ICow6BS8OCtB2nJNma0M
=XJMR
-----END PGP SIGNATURE-----

--------------enig038063C610A34E6E1F72D3E7--


--===============2788333783859921421==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
--===============2788333783859921421==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============2788333783859921421==--
