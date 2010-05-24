From: Shirley Ma <mashirle@us.ibm.com>
Subject: RE: ixgbe: macvlan on PF/VF when SRIOV is enabled
Date: Mon, 24 May 2010 10:08:39 -0700
Message-ID: <1274720919.18023.19.camel@localhost.localdomain>
References: <1274473846.8701.25.camel@localhost.localdomain>
	 <43F901BD926A4E43B106BF17856F0755A79C099C@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <43F901BD926A4E43B106BF17856F0755A79C099C@orsmsx508.amr.corp.intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Greg,

Thanks for your prompt response.

On Sat, 2010-05-22 at 10:53 -0700, Rose, Gregory V wrote:
> As of 2.6.34 the ixgbe driver does not support multiple queues for
> macvlan.
> Support for multiple queues for macvlan will come in a subsequent
> release.

When it might happen? I will double check my test to see whether macvlan
was multiple queue or not. Then submitting my experimental patch for
review.

> The VF driver does not support macvlan.  Future releases may but there
> are no immediate plans to support it.

When it might be support in future. For performance reason, we are
interested in macvlan + VF for multiples VMs.

One more question here: Does VF support promiscuous mode? I don't see
the flag in ixgbevf driver.

Thanks
Shirley

