From: Patrick McHardy <kaber@trash.net>
Subject: Re: Connection tracking and vlan
Date: Mon, 02 Nov 2009 17:48:41 +0100
Message-ID: <4AEF0D69.7070205@trash.net>
References: <20091030152054.GA7936@gondor.apana.org.au>	 <4AEB06E6.6020206@gmail.com>	 <fb7befa20910301220y53e43608u3b37de17661feb4e@mail.gmail.com>	 <m1639wmq1f.fsf@fess.ebiederm.org> <4AEB75DD.8050204@candelatech.com> <fb7befa20911020814q2c4bcd1bj7e2b5a4c17ba0f89@mail.gmail.com> <4AEF09E7.2010004@trash.net> <4AEF0BAA.7050800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adayadil Thomas <adayadil.thomas@gmail.com>,
	Ben Greear <greearb@candelatech.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4AEF0BAA.7050800@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Patrick McHardy a =E9crit :
>> But it would be preferrable if we could do this using network
>> namespaces somehow.
>=20
> eg eth0.100 and eth0.101 on namespace 1,  eth0.200 and eth0.201 on na=
mespace 2 ?
>=20
> Can we do that with current kernel ? (different vlans on an unique ph=
ysical device)

By default the underlying device needs to exist in the same namespace
in which the VLAN device is created. I believe it should be possible
to move the VLAN device to a different namespace after creating it,
but I'm not sure about that.

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
