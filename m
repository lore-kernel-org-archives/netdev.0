From: Thomas Zeitlhofer <thomas.zeitlhofer@nt.tuwien.ac.at>
Subject: Re: tuntap regression in v3.9.8 and v3.10
Date: Fri, 5 Jul 2013 15:02:07 +0200
Message-ID: <20130705130207.GA27485@toau.bambla>
References: <20130702195910.GA20271@toau.bambla>
 <CAOMZO5B7Yx7tRy8Q5wi6ngcD0FDJzKXHOEGPXyUo52+f3oUHEg@mail.gmail.com>
 <20130702220651.GA23097@toau.bambla>
 <51D39010.5090902@redhat.com>
 <20130703061104.GA22847@toau.bambla>
 <51D640E2.1010809@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Fabio Estevam <festevam@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <51D640E2.1010809@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 05, 2013 at 11:43:30AM +0800, Jason Wang wrote:
> On 07/03/2013 02:11 PM, Thomas Zeitlhofer wrote:
> > Hello Jason,
> >
> > On Wed, Jul 03, 2013 at 10:44:32AM +0800, Jason Wang wrote:
[...]
> >> Which regression did you see?
> > a kernel panic on the host machine. The details are in the first message
> > of this thread: http://lkml.org/lkml/2013/7/2/499
> 
> Could you please have a try with the patch in
> https://lkml.org/lkml/2013/6/25/304.

I can confirm that this patch fixes the problem. Tried it against v3.10
and there are no issues any more when live migrating virtual machines
off the host machine that runs v3.10 + this patch.

Thanks,

Thomas
