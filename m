From: Chuck Ebbert <76306.1226@compuserve.com>
Subject: Re: [PATCH] Optimize loopback stats
Date: Tue, 15 Mar 2005 18:15:59 -0500
Message-ID: <200503151819_MC3-1-98A4-43AC@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
	 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>,
        linux-netdev <netdev@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 15-Mar-05 Nivedita Singhvi wrote:

> Chuck Ebbert wrote:
>
> >   This patch optimizes the loopback driver's statistics by using a single
> > counter for rx and tx stats instead of one for rx and one for tx.  It also
> > adds unlikely() to the test for TSO since it's no longer supported by default.
> > (Maybe the TSO code should be bracketed by "#if 0" ?)
>
> Hmm, some of us want those counters separate - if this is really
> needed, could it be a configurable option, please?

 But they _are_ separately reported -- get_stats() takes care of that.
Everything looks exactly the same to userspace after this patch.




--
Chuck
