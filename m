From: Joe Perches <joe@perches.com>
Subject: Re: Treewide frequency of various checkpatch messages
Date: Mon, 10 Mar 2014 13:11:56 -0700
Message-ID: <1394482316.21085.8.camel@joe-AO722>
References: <1394104358-23438-1-git-send-email-kys@microsoft.com>
	 <1394104390-23477-1-git-send-email-kys@microsoft.com>
	 <20140306.142919.763823800315842610.davem@davemloft.net>
	 <1394148520.16156.8.camel@joe-AO722> <20140307075247.GA29018@mwanda>
	 <1394184637.16156.58.camel@joe-AO722> <1394467346.24244.14.camel@joe-AO722>
	 <20140310165046.GA12687@kroah.com> <1394477330.24244.34.camel@joe-AO722>
	 <20140310193346.GA2850@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	apw@canonical.com, devel@linuxdriverproject.org,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140310193346.GA2850@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-03-10 at 12:33 -0700, Greg KH wrote:
> On Mon, Mar 10, 2014 at 11:48:50AM -0700, Joe Perches wrote:
[]
> > I've no strong opinion of the need to write code
> > like:
> > 
> > {
> >         u32 iterations = 0;
> > 
> >         while (arch_spin_is_locked(lock))
> >                 delay_backoff(iterations++);
> > }
> 
> I wonder if there's a way to "count" the size of the function, and only
> complain if it's longer than 4-5 lines long?

No, there's isn't really.
checkpatch works on patch hunks.
The function scope isn't necessarily visible.
