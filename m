From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCHv2 for-3.9] pci: avoid work_on_cpu for nested SRIOV probes
Date: Fri, 19 Apr 2013 10:39:59 -0600
Message-ID: <CAErSpo4PM9OhjK83OCQNrS-P6Xx8A3DzTVbDiRLn4dToa9aovA@mail.gmail.com>
References: <51360D7C.3060209@mellanox.com> <20130418200855.GA24086@redhat.com>
 <CAErSpo65Q0+UT3sS6LcyXohkCMfjweoS_j+okiYq4bdjFKjdHw@mail.gmail.com>
 <CAErSpo7jf-ytJPhuphzLFH80c9YMM6UzxWAVEnD-25nQgXmARQ@mail.gmail.com> <CAOS58YO+uV5KkS=sTP9Y3BPPh1nVnQ06yRyNU8GvEbym7R+X+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
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
In-Reply-To: <CAOS58YO+uV5KkS=sTP9Y3BPPh1nVnQ06yRyNU8GvEbym7R+X+Q@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 18, 2013 at 9:04 PM, Tejun Heo <tj@kernel.org> wrote:
> So, the thing is there is no actual deadlock. If you're okay with releasing
> w/ spurious lockdep warning, leaving things alone should be fine. An issue
> with mst's patch is that it actually changes the behavior to avoid a
> spurious warning. An alternative course would be leaving it alone now and
> remove the spurious warning during the coming devel cycle and mark it w/
> -stable.

If I understand correctly, you need v3.9-rc1 or later,
CONFIG_PROVE_LOCKING=y, and an SR-IOV device to see the warning.

I like the idea of fixing the spurious warning for v3.10 and
backporting to -stable.  It sounds like there's a cleaner fix in the
works that needs a bit more polishing.  If we need a quick fix sooner,
we'll still have this one in our back       pocket.

Bjorn
