From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [RFC] ipv4: add ICMP socket kind
Date: Wed, 22 Dec 2010 14:03:18 +0300
Message-ID: <20101222110318.GA6224@albatros>
References: <20101221181800.GA8166@albatros>
 <AANLkTikS6rs-AFGmtTfuRdELJ5+y=o4g1i0Xk9KDFRiv@mail.gmail.com>
 <20101221194606.GA25359@openwall.com>
 <AANLkTin6_fck1SbCbX5tLvY8CPzJstqmpkJuVF-B6oC6@mail.gmail.com>
 <20101221213212.GA26006@openwall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin Walters <walters@verbum.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>
To: Solar Designer <solar@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101221213212.GA26006@openwall.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 22, 2010 at 00:32 +0300, Solar Designer wrote:
> We use OpenVZ containers
> heavily, and we don't want to run an instance of such process per
> container (up to a few hundred per system).

Besides memory usage daemons cannot allocate reliably unique icmp echo
identifiers as they don't know anything about already assigned idents.


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
