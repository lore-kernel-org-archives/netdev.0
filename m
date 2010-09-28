From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: BUG - qdev - partial loss of network connectivity
Date: Tue, 28 Sep 2010 11:50:58 +0200
Message-ID: <20100928095058.GI12472@redhat.com>
References: <20100922171832.GA28721@moo.pl> <4C9A3FAF.9090503@codemonkey.ws>
	<20100922182049.GA29263@moo.pl> <4C9A4C77.2080806@codemonkey.ws>
	<20100923140437.GA9256@moo.pl> <20100926154324.GD21843@redhat.com>
	<20100927213203.GA28089@moo.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org, qemu-devel@nongnu.org,
	virtualization@lists.linux-foundation.org
To: Leszek Urbanski <tygrys@moo.pl>
Return-path: <qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org>
Content-Disposition: inline
In-Reply-To: <20100927213203.GA28089@moo.pl>
List-Unsubscribe: <http://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=unsubscribe>
List-Archive: <http://lists.nongnu.org/archive/html/qemu-devel>
List-Post: <mailto:qemu-devel@nongnu.org>
List-Help: <mailto:qemu-devel-request@nongnu.org?subject=help>
List-Subscribe: <http://lists.nongnu.org/mailman/listinfo/qemu-devel>,
	<mailto:qemu-devel-request@nongnu.org?subject=subscribe>
Sender: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
Errors-To: qemu-devel-bounces+gceq-qemu-devel=gmane.org@nongnu.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2010 at 11:32:03PM +0200, Leszek Urbanski wrote:
> <20100926154324.GD21843@redhat.com>; from Michael S. Tsirkin on Sun, Sep 26, 2010 at 17:43:24 +0200
> 
> > > > >It's vanilla 2.6.32.22, but I also reproduced this on Debian's 2.6.32-23
> > > > >(based on 2.6.32.21).
> > > > >
> > > > >If offload is the only difference, I'll play with different offload
> > > > >options and check which one causes it.
> > > > >   
> > > > 
> > > > It's not technically the only difference but it's the most likely 
> > > > culprit IMHO.
> > > 
> > > udp fragmentation offload is definitely the culprit.
> > 
> > I see. Most likely guest bug - won't be the first bug around UFO.
> > If so pls copy netdev linux-nfs and virtualization.
> > Do you see anything in dmesg? Can try 2.6.36-rc5?
> 
> (for reference: first post is at:
> http://lists.nongnu.org/archive/html/qemu-devel/2010-09/msg01685.html )
> 
> I can't reproduce it on 2.6.36-rc5. Do you have an idea which patch may have
> fixed it, or should I dissect?

bisect, yes: there were many UFO related patches since 2.6.32.

-- 
MST
