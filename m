From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH] cxgb4: use dev_port to identify ports
Date: Wed, 25 Jun 2014 16:08:21 -0700
Message-ID: <CAB=NE6VWa4O0nycSo55ip075MEXXB_0k4wVnorSziRQmKRUmLg@mail.gmail.com>
References: <1403354888-15600-1-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hariprasad Shenai <hariprasad@chelsio.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403354888-15600-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 21, 2014 at 5:48 AM, Thadeu Lima de Souza Cascardo
<cascardo@linux.vnet.ibm.com> wrote:
> That use was removed by commit
> 8c367fcbe6549195d2eb11e62bea233f811aad41 ("cxgb4: Do not set
> net_device::dev_id to VI index"), since dev_id should be used only when
> devices share the same MAC address.
>
> Using dev_port for cxgb4 allows different ports on the same PCI function
> to be identified.

Can you describe what issues were introduced because of this then?

  Luis
