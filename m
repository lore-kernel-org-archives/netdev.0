From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: Re: [PATCH 01/24] sysctl: net: call unregister_net_sysctl_table where needed
Date: Wed, 6 Apr 2011 22:04:53 +0200
Message-ID: <BANLkTik6PKYFyjnGLWoeRBrwF4sPZaaGWw@mail.gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
 <05ae3c2fdd2db1f6a2fd3cd900164667e615f4f8.1301711868.git.lucian.grijincu@gmail.com>
 <20110406.125256.102558618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: adobriyan@gmail.com, ebiederm@xmission.com, tavi@cs.pub.ro,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110406.125256.102558618.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 6, 2011 at 9:52 PM, David Miller <davem@davemloft.net> wrot=
e:
> Oops, hmmm... =C2=A0Can this actually cause any real problems current=
ly?
>
> If so I'd like to toss this specific patch into net-2.6


Nope:

void unregister_net_sysctl_table(struct ctl_table_header *header)
{
        unregister_sysctl_table(header);
}
EXPORT_SYMBOL_GPL(unregister_net_sysctl_table);

But I thought that in the future, if something special needs to be
done for unregister_net_sysctl_table, it would be better to have these
consistent. I'll do a check on all the tree to see if there are other
cases.

Another approach would be to remove unregister_net_sysctl_table, as it
does nothing different of unregister_sysctl_table and let our future
selves deal with the problem.

Can you tell me what you'd like?

--=20
=C2=A0.
=2E.: Lucian
