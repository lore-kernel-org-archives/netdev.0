From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [net-next PATCH 1/5] bpf: introduce new bpf cpu map type
 BPF_MAP_TYPE_CPUMAP
Date: Fri, 29 Sep 2017 11:37:37 +0200
Message-ID: <1506677857.2478.5.camel@redhat.com>
References: <150660339205.2808.7084136789768233829.stgit@firesoul>
         <150660342793.2808.10838498581615265043.stgit@firesoul>
         <20170929032146.vs5v454wjs4niu4k@ast-mbp>
         <8737760wg5.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>, edumazet@google.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750847AbdI2Jhp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 05:37:45 -0400
In-Reply-To: <8737760wg5.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-09-29 at 09:56 +0200, Hannes Frederic Sowa wrote:
> [adding Paolo, Eric]
> 
> Alexei Starovoitov <alexei.starovoitov@gmail.com> writes:
> 
> > On Thu, Sep 28, 2017 at 02:57:08PM +0200, Jesper Dangaard Brouer wrote:
> 
> [...]
> 
> > > +	wake_up_process(rcpu->kthread);
> > 
> > In general the whole thing looks like 'threaded NAPI' that Hannes was
> > proposing some time back. I liked it back then and I like it now.
> > I don't remember what were the objections back then.
> > Something scheduler related?
> > Adding Hannes.

Beyond the added scheduling complexity, the threaded NAPI
implementation proposed some time ago also possibly introduced OoO
packet delivery, because the NAPI threads were left unbound to any CPU.

Cheers,

Paolo
