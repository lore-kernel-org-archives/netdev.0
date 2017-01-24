From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [patch net-next] sctp: fix some debug output
Date: Tue, 24 Jan 2017 11:00:41 -0200
Message-ID: <20170124130041.GF3781@localhost.localdomain>
References: <20170124090540.GA27652@mwanda>
 <20170124091411.GE3781@localhost.localdomain>
 <20170124105007.GF4201@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        Xin Long <lucien.xin@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org,
        Colin King <colin.king@canonical.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170124105007.GF4201@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 24, 2017 at 01:50:07PM +0300, Dan Carpenter wrote:
> On Tue, Jan 24, 2017 at 07:14:11AM -0200, Marcelo Ricardo Leitner wrote:
> > On Tue, Jan 24, 2017 at 12:05:40PM +0300, Dan Carpenter wrote:
> > > We added SCTP_EVENT_TIMEOUT_RECONF but we didn't update this array so
> > > it causes an off-by-one read overflow.
> > > 
> > > Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
> > > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > Weird, seems your patch is missing the --- marker here.
> 
> Are there tools that require the --- marker?  I normally leave it out
> when it's not required.

Yeah I don't think it's required. It's usually there to split it between
changelog and non-changelog stuff like the diffstat output, which is not
there too, so it should be okay.

  Marcelo
