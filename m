From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH 6/7] PCI: Make sure VF's driver get attached after PF's
Date: Thu, 16 May 2013 00:56:42 -0400
Message-ID: <CAJZOPZLVc=V-ac8_A2JB_r17TRyCMoDpe1MXN6WcjMR4SO6n1Q@mail.gmail.com>
References: <1368498506-25857-1-git-send-email-yinghai@kernel.org>
	<1368498506-25857-7-git-send-email-yinghai@kernel.org>
	<0EE9A1CDC8D6434DB00095CD7DB873462CFB0E4E@MTLDAG01.mtl.com>
	<CAE9FiQVn4F+dTrQn0xsg-6QY9+HwbnJR=1CrjdoZkmF_LMrgpg@mail.gmail.com>
	<CAJZOPZLjdALP4jkLo6p787jaPx=dkKj7+AmCr9+mgJN3z_xBxQ@mail.gmail.com>
	<CAE9FiQWvYQRCZjDx-Kh16nKfjfS=pyu8foJR+wWYS-x8DUZteg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yan Burman <yanb@mellanox.com>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Gu Zheng <guz.fnst@cn.fujitsu.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAE9FiQWvYQRCZjDx-Kh16nKfjfS=pyu8foJR+wWYS-x8DUZteg@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 16, 2013 at 12:39 AM, Yinghai Lu <yinghai@kernel.org> wrote:
>
> On Wed, May 15, 2013 at 9:00 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
> > On Tue, May 14, 2013 at 11:43 AM, Yinghai Lu <yinghai@kernel.org> wrote:
> >
> >> BTW, do you have any plan to make mlx4 support sriov_configure via
> >> sysfs?
> >
> > yes we do, we're waiting for a firmware change that will allow for
> > such a patch to get working.
> >
> > Please note that this whole lockdep warning was identified as false
> > positive by Tejun http://www.spinics.net/lists/linux-pci/msg21568.html
>
> No, at least one time, I noticed there is one real hang happens.

Tejun, so what your thinking here?
