From: James Morris <jmorris@namei.org>
Subject: Re: linux-next: manual merge of the security-testing tree with the
 net tree
Date: Mon, 10 Jan 2011 09:48:58 +1100 (EST)
Message-ID: <alpine.LRH.2.00.1101100948490.20106@tundra.namei.org>
References: <20110107114400.e4d1d33b.sfr@canb.auug.org.au> <4D2666D0.9060802@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <4D2666D0.9060802@schaufler-ca.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 6 Jan 2011, Casey Schaufler wrote:

> On 1/6/2011 4:44 PM, Stephen Rothwell wrote:
> > Hi James,
> >
> > Today's linux-next merge of the security-testing tree got a conflict in
> > security/smack/smack_lsm.c between commit
> > 3610cda53f247e176bcbb7a7cca64bc53b12acdb ("af_unix: Avoid socket->sk NULL
> > OOPS in stream connect security hooks") from the net tree and commit
> > b4e0d5f0791bd6dd12a1c1edea0340969c7c1f90 ("Smack: UDS revision") from the
> > security-testing tree.
> >
> > I fixed it up (I think - see below) and can carry the fix as necessary.
> 
> The change looks like it addresses the change in interface. Thank you.

Thanks, applied.


-- 
James Morris
<jmorris@namei.org>
