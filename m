From: Michael Bellion and Thomas Heinz <nf@hipac.org>
Subject: Re: [RFC] High Performance Packet Classifiction for tc framework
Date: Tue, 12 Aug 2003 16:56:20 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3F390014.1080708@hipac.org>
References: <200307141045.40999.nf@hipac.org>	 <1058328537.1797.24.camel@jzny.localdomain>  <3F16A0E5.1080007@hipac.org>	 <1059934468.1103.41.camel@jzny.localdomain>  <3F2E5CD6.4030500@hipac.org>	 <1060012260.1103.380.camel@jzny.localdomain>  <3F302E04.1090503@hipac.org>	 <1060286331.1025.73.camel@jzny.localdomain>  <3F381B3E.6080807@hipac.org> <1060657028.1028.79.camel@jzny.localdomain>
Reply-To: nf@hipac.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF71BC491D1932543B4535ECA"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: hadi@cyberus.ca
In-Reply-To: <1060657028.1028.79.camel@jzny.localdomain>
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF71BC491D1932543B4535ECA
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Jamal

You wrote:
> Some fires scare even brave firemen. This was a brave fireman until he
> saw the fire ;->

LOL :-)

> I have to go back and read the theory again to fully comprehend it but
> intutively you are right. I claim that if you knew your input well then
> you could construct a hash which will closely approach perfect hashing.
> So if i was to use the example you gave me earlier i could approximate a
> o(1) hash. u32 allows me to do so once i know how things will look like.
> Of course i have to do that mnaully with a pencil and paper.

Apart from the fact that the "pencil and paper" approach is not
feasible for complex examples where there are no strict regularities
in the rule set, you simply cannot avoid the implications when
choosing a certain prefix length for the hash (as described in the
previous posting). So probably in most cases even "pencil and paper"
won't help.

> yes. But note the caveat i put above on knowing the input and being able
> to manually use a pencil to map out the hash. Now automate the pencil
> and paper and let some cpu analyse the traffic patterns as well as
> adjust the hashes ... maybe a thesis for someone.

Yes, maybe someone should dig further but as long as the
assumptions stay the same you have to live with the consequences
stated in our last posting.

> well, with the iptables scheme at least you need to know where to insert
> the rules; so theres some manual labor involved there as well ;->
> Out of curiosity with such a model how do you define a default rule?
> In the prio model(and tc), you can have a default catchall rule in the
> lowest priority, this way should higher prios fail this will catchall.

In theory the default rule has priority "infinity".
In an implementation you can simply choose the priority of the default
rule 1 + max{prio(r) | for all rules r}. So it's increased by 1 for
every insert operation.

> Ok, i see your point, so you are saying that a tcf_result is infact a
> hardcoded action which should probably be called "setclassid".
> Interesting thought.

Yes :-)

>>Each rule can only have one action or return "value"
>>attached to it so if we want to use embedded classifiers
>>(as matches) their classid (= action) must be ignored.
> 
> you want the "continue" action essentially.

Sorry but we don't seem to get your point here.
How is the "continue" action related to having multiple
embedded classifiers in a rule which essentially provides
1 single action?

> I think i finally see your point. Yes, this could be an improvement that
> could be made to tc. Infact you have motivated me to write a
> "setclassid" action which will override the classid defined otherwise.

:-)


Regards,

+-----------------------+----------------------+
|   Michael Bellion     |     Thomas Heinz     |
| <mbellion@hipac.org>  |  <creatix@hipac.org> |
+-----------------------+----------------------+
|    High Performance Packet Classification    |
|       nf-hipac: http://www.hipac.org/        |
+----------------------------------------------+

--------------enigF71BC491D1932543B4535ECA
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)
Comment: Using GnuPG with Debian - http://enigmail.mozdev.org

iD8DBQE/OQAWtXh2AYIMjggRAtgjAJ40cItzNYeTc605D3teq+pn1QIa4ACgm1cU
AMOaSmtZdxq6NKycGGEzR4I=
=Crtj
-----END PGP SIGNATURE-----

--------------enigF71BC491D1932543B4535ECA--

