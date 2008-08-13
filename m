From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Wed, 13 Aug 2008 10:00:28 +0200
Message-ID: <200808131000.29788.thomas.jarosch@intra2net.com>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi> <200808120946.19459.thomas.jarosch@intra2net.com> <20080812.011822.155249871.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, billfink@mindspring.com,
	fragabr@gmail.com, netdev@vger.kernel.org, kaber@trash.net,
	sr@securenet.de, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080812.011822.155249871.davem@davemloft.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, 12. August 2008 10:18:22 David Miller wrote:
> From: Thomas Jarosch <thomas.jarosch@intra2net.com>
> Date: Tue, 12 Aug 2008 09:46:17 +0200
>
> > David, I agree with you, though I'm not sure about the end user
> > experience:
>
> We had the same situation with ECN and window scaling, and my proposal
> is the same as how we handled those situations involving broken
> middleware boxes.

Yes, that is true. IMHO there's a slight difference with FRTO trouble
compared to ECN/window scaling issues:

ECN trouble -> No access at all
Broken window scaling -> Large transfers don't work
MTU issues -> No access at all / large transfers don't work

FRTO problems -> Hard to spot as they only happen when packet loss occurs.
Though I guess Ilpo knows best if there's an "easy" way to detect this or not.

Thomas
