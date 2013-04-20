From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Sat, 20 Apr 2013 22:05:04 +0300
Message-ID: <20130420190504.GB853@redhat.com>
References: <51360D7C.3060209@mellanox.com>
 <20130418200855.GA24086@redhat.com>
 <CAErSpo65Q0+UT3sS6LcyXohkCMfjweoS_j+okiYq4bdjFKjdHw@mail.gmail.com>
 <CAErSpo7jf-ytJPhuphzLFH80c9YMM6UzxWAVEnD-25nQgXmARQ@mail.gmail.com>
 <CAOS58YO+uV5KkS=sTP9Y3BPPh1nVnQ06yRyNU8GvEbym7R+X+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAOS58YO+uV5KkS=sTP9Y3BPPh1nVnQ06yRyNU8GvEbym7R+X+Q@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 08:04:47PM -0700, Tejun Heo wrote:
> So, the thing is there is no actual deadlock. If you're okay with releasing w/
> spurious lockdep warning, leaving things alone should be fine. An issue with
> mst's patch is that it actually changes the behavior to avoid a spurious
> warning.

Yes but in fact, isn't it cleaner to avoid work_on if we are going to run
on the local CPU, anyway?

> An alternative course would be leaving it alone now and remove the
> spurious warning during the coming devel cycle and mark it w/ -stable.
> 
> Thanks.

Okay. Could you send tested a version of work_on_nested?

> --
> tejun
