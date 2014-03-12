From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH RFC 0/9] socket filtering using nf_tables
Date: Wed, 12 Mar 2014 10:27:07 +0100
Message-ID: <20140312092707.GA4973@localhost>
References: <1394529560-3490-1-git-send-email-pablo@netfilter.org>
 <531EE5A2.7090501@redhat.com>
 <CAMEtUuyJne-8uNtOAK7EcFFQNXz9m7J2DDLGH_GbYe6oWZx1pQ@mail.gmail.com>
 <20140312091500.GA4638@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>, kaber@trash.net,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140312091500.GA4638@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 12, 2014 at 10:15:00AM +0100, Pablo Neira Ayuso wrote:
> > 7/9:
> > whole nft_expr_autoload() looks scary from security point of view.
> > If I'm reading it correctly, the code will do request_module() based on
> > userspace request to attach filter?
> 
> Only root can invoke that code so far.

Oops, this is obviously wrong. This request_module part needs a fix
indeed for the non-root part.
