From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] bpf: fix a false positive kmemcheck warning
Date: Fri, 05 Sep 2014 19:34:51 +0200
Message-ID: <5409F43B.1050900@redhat.com>
References: <alpine.LRH.2.02.1409051157440.5269@file01.intranet.prod.int.rdu2.redhat.com> <5409E2C8.2080200@redhat.com> <1409936457.5306.2.camel@localhost> <5409EE70.9020304@redhat.com> <alpine.LRH.2.02.1409051313350.5269@file01.intranet.prod.int.rdu2.redhat.com> <5409F032.50101@redhat.com> <CAMEtUuyX8Oak48vS+EDLmHY6p0yjrYNr9YXLNEYJsS7HsuooRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mikulas Patocka <mpatocka@redhat.com>,
	Hannes Frederic Sowa <hannes@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuyX8Oak48vS+EDLmHY6p0yjrYNr9YXLNEYJsS7HsuooRg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/05/2014 07:21 PM, Alexei Starovoitov wrote:
...
> imo it's cleaner to convert to bool unconditionally instead
> of annotating things everywhere.

Will do, fine as well.
