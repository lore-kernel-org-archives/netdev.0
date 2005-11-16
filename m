From: "John W. Linville" <linville@redhat.com>
Subject: Re: fedora-netdev.1 IPv6 freeze [Re: [ANNOUNCE] fedora-netdev
	kernel repository]
Date: Wed, 16 Nov 2005 09:25:18 -0500
Message-ID: <20051116142518.GE8356@redhat.com>
References: <20051114205110.GK25755@redhat.com>
	<Pine.LNX.4.64.0511161242260.26498@netcore.fi>
	<20051116114224.GB20395@postel.suug.ch>
Reply-To: Development discussions related to Fedora Core <fedora-devel-list@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Development discussions related to Fedora Core <fedora-devel-list@redhat.com>,
	netdev@vger.kernel.org, Pekka Savola <pekkas@netcore.fi>,
	linville@tuxdriver.com
Return-path: <fedora-devel-list-bounces@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20051116114224.GB20395@postel.suug.ch>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-devel-list>,
	<mailto:fedora-devel-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-devel-list>
List-Post: <mailto:fedora-devel-list@redhat.com>
List-Help: <mailto:fedora-devel-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-devel-list>,
	<mailto:fedora-devel-list-request@redhat.com?subject=subscribe>
Sender: fedora-devel-list-bounces@redhat.com
Errors-To: fedora-devel-list-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 16, 2005 at 12:42:24PM +0100, Thomas Graf wrote:
> * Pekka Savola <pekkas@netcore.fi> 2005-11-16 12:46
> > On Mon, 14 Nov 2005, John W. Linville wrote:
> > >	http://people.redhat.com/linville/kernels/fedora-netdev/
> > 
> > I guess the test can be termed a 'success' because after updating from 
> > 2.6.14-1.1637_FC4 to 2.6.14-1.1637_FC4.netdev.1, I get 100% 
> > reproducible kernel hang (everything just freezes as it is, no message 
> > to /var/log/messages or anywhere) after I run '/sbin/ip -6 r l' or try 
> > to use IPv6 in basically any other way on my ThinkPad laptop with 
> > external orinoco_cs WLAN card.
> > 
> > Any thoughts for the next steps?
> 
> It's probably missing this patch:

It was...

Pekka, I have included the patch Thomas identified as part of the
FC4.netdev.2 build.  You may want to do a 'yum update' and try it out.

Thanks!

John
-- 
John W. Linville
linville@redhat.com

-- 
fedora-devel-list mailing list
fedora-devel-list@redhat.com
https://www.redhat.com/mailman/listinfo/fedora-devel-list
