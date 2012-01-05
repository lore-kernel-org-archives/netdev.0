From: Eric Paris <eparis@redhat.com>
Subject: Re: linux-next: manual merge of the selinux tree with the net-next
 tree
Date: Thu, 05 Jan 2012 17:51:49 -0500
Message-ID: <1325803909.17118.17.camel@localhost>
References: <20120105151255.f72ad113a93493bb55844034@canb.auug.org.au>
	 <27624574.j8RvKjachg@sifl>
	 <20120106091550.534131cb1fe6e3dee323699c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Moore <pmoore@redhat.com>, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrei Emeltchenko <andrei.emeltchenko@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120106091550.534131cb1fe6e3dee323699c@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-01-06 at 09:15 +1100, Stephen Rothwell wrote:
> Hi Paul,
> 
> On Thu, 05 Jan 2012 16:25:53 -0500 Paul Moore <pmoore@redhat.com> wrote:
> >
> > On Thursday, January 05, 2012 03:12:55 PM Stephen Rothwell wrote:
> > > 
> > > Today's linux-next merge of the selinux tree got a conflict in
> > > net/bluetooth/l2cap_sock.c between commit 15770b1ab974 ("Bluetooth:
> > > convert force_active variable to flag in l2cap chan") from the net-next
> > > tree and commit 53860f3d0499 ("bluetooth: Properly clone LSM attributes
> > > to newly created child connections") from the selinux tree.
> > > 
> > > These both remove the same line, but there is probably something more
> > > subtle going on ...  I just used the version from the net-next tree.
> > 
> > Something is a bit odd.  When I look in the current linux-next tree I see two 
> > commits which fix a Bluetooth/LSM bug; the first is correct, the second one 
> > appears to be some other commit which just hijacked the description from the 
> > first ... I have no idea what is going on in the second commit; I'll leave 
> > that to you git gurus :)
> > 
> >  * Correct commit -> 6230c9b4f8957c8938ee4cf2d03166d3c2dc89de
> 
> That is a commit in Linus' tree before v3.1
> 
> >  * Garbage commit -> 53860f3d0499992855d58e33f0f79bfe642dfccb
> 
> That is the commit in the selinux tree.  This should be unnecessary as
> the selinux tree is based on v3.1 (and I basically ignored it in the
> merge resolution).

Thanks paul...  This must be a result of me rebasing my tree onto 3.1.
No way I should have left this garbage.  It doesn't make sense.  I think
I'll rewrite history for tomorrow since noone is going to notice or
care...

-Eric
