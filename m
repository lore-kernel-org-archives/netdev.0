From: Greg KH <greg@kroah.com>
Subject: Re: [stable request <= 3.11] net/mlx4_en: Fix BlueFlame race
Date: Tue, 18 Nov 2014 17:44:46 -0800
Message-ID: <20141119014446.GH22731@kroah.com>
References: <CAHA+R7OyLv2YO8AduNhnEgW3RyYZwWNEHY6W-v_HXgVT9AOaKw@mail.gmail.com>
 <20141101.134142.888127846627939710.davem@davemloft.net>
 <CAHA+R7OMgOpnWyy5E55OtLS4naOcZ5EhzViE14Yffu=K=TqNcA@mail.gmail.com>
 <20141103.150917.1015521239616746570.davem@davemloft.net>
 <CAHTgTXWcSa0LaGd7+v+8eCLPPQ=ZNkttHuhbhx=ibW1DoDMPCA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, cwang@twopensource.com,
	ben@decadent.org.uk, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Matan Barak <matanb@mellanox.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Vinson Lee <vlee@twopensource.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAHTgTXWcSa0LaGd7+v+8eCLPPQ=ZNkttHuhbhx=ibW1DoDMPCA@mail.gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 05, 2014 at 11:38:37AM -0800, Vinson Lee wrote:
> On Mon, Nov 3, 2014 at 12:09 PM, David Miller <davem@davemloft.net> wrote:
> > From: Cong Wang <cwang@twopensource.com>
> > Date: Mon, 3 Nov 2014 09:22:18 -0800
> >
> >> On Sat, Nov 1, 2014 at 10:41 AM, David Miller <davem@davemloft.net> wrote:
> >>>
> >>> There is no documented way nor do I wish to state anything so strictly.
> >>> I want maximum flexibility for such a time consuming task.
> >>>
> >>> I tend to go back 3 or 4 releases at most, and it really depends upon
> >>> the difficulty of the backports and my own time constraints.
> >>
> >> You should really offload to developers, otherwise too much work for you. :)
> >
> > That's exactly what I am doing by having the -stable maintainers for older
> > releases deal with the backports and other pains.
> 
> + stable
> 
> Please backport upstream commit
> 2d4b646613d6b12175b017aca18113945af1faf3 "net/mlx4_en: Fix BlueFlame
> race" to stable kernels. David is no longer supporting 3.10 and older.
> 
> Please refer to http://marc.info/?l=linux-netdev&m=141366689811844 for
> previous comments in thread.

Now applied, thanks.

greg k-h
