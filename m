From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH 1/1 net-next] ieee802154: fix __init functions
Date: Wed, 1 Oct 2014 08:08:14 +0200
Message-ID: <20141001060812.GA23043@omega>
References: <1412141266-12258-1-git-send-email-fabf@skynet.be>
 <56FE06A5-5C2A-42E4-B01A-15EB36BAADE5@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Fabian Frederick <fabf@skynet.be>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56FE06A5-5C2A-42E4-B01A-15EB36BAADE5@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Oct 01, 2014 at 07:34:39AM +0200, Marcel Holtmann wrote:
> Hi Fabian,
> 
> > Commit 3243acd37fd9
> > ("ieee802154: add __init to lowpan_frags_sysctl_register")
> > 
> > added __init to lowpan_frags_ns_sysctl_register instead of
> > lowpan_frags_sysctl_register
> > 
> > Suggested-by: Alexander Aring <alex.aring@gmail.com>
> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> > ---
> > net/ieee802154/reassembly.c | 4 ++--
> > 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> when trying to apply this to bluetooth-next kernel, I am getting this:
> 
> Applying: ieee802154: fix __init functions
> error: patch failed: net/ieee802154/reassembly.c:498
> error: net/ieee802154/reassembly.c: patch does not apply
> Patch failed at 0001 ieee802154: fix __init functions
> 

Fabian:
thanks.


Marcel:
this is a patch for a fix which is already in net-next. Please don't
apply, see [0].


Marcel and David:
Now, we have chaos who will apply now patches for ieee802154. I thought
I apply ieee802154 patches to the wpan-next tree and then send it to
bluetooth-next. Please don't change this patchflow.

Okay, I know sometimes people change the inet_frag api, then it should
go into net/net-next.


- Alex

[0] http://marc.info/?l=linux-netdev&m=141213852806003&w=2
