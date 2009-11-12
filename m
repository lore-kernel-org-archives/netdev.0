From: Joel Becker <Joel.Becker@oracle.com>
Subject: Re: [patch] Fix: 'return -ENOMEM' instead of 'return
	ENOMEM'
Date: Thu, 12 Nov 2009 12:27:29 -0800
Message-ID: <20091112202728.GC22985@mail.oracle.com>
References: <4AFB2C0B.50605@gmail.com>
	<20091111134730.a0da9e38.akpm@linux-foundation.org>
	<20091112081043.GA25345@elte.hu>
	<20091112191758.GA22985@mail.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
        "Stephen M. Cameron" <scameron@beardog.cca.cpqcorp.net>,
        Mike Christie <michaelc@cs.wisc.edu>, David Airlie <airlied@linux.ie>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Jens Axboe <jens.axboe@oracle.com>, Evgeniy Polyakov <zbr@ioremap.net>,
        iss_storagedev@hp.com, Eric Dumazet <eric.dumazet@gmail.com>,
        Andy Whitcroft <apw@shadowen.org>, Dave Airlie <airlied@redhat.com>,
        Hannes Eder <hannes@hanneseder.net>, dri-devel@lists.sourceforge.net,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Mike Miller <mike.miller@hp.com>, Mark Fasheh <mfasheh@suse.com>,
        Karsten Keil <isdn@linux-pingi.de>, rostedt@goodmis.org,
        Karen Xie <kxie@chelsio.com>,
        "James E.J. Bottomley" <James.Bottomley@suse.de>,
        Hannes Reinecke <hare@suse.de>,
        Andreas Ever
To: Ingo Molnar <mingo@elte.hu>
Return-path: <ocfs2-devel-bounces@oss.oracle.com>
Content-Disposition: inline
In-Reply-To: <20091112191758.GA22985@mail.oracle.com>
List-Unsubscribe: <http://oss.oracle.com/mailman/listinfo/ocfs2-devel>,
	<mailto:ocfs2-devel-request@oss.oracle.com?subject=unsubscribe>
List-Archive: <http://oss.oracle.com/pipermail/ocfs2-devel>
List-Post: <mailto:ocfs2-devel@oss.oracle.com>
List-Help: <mailto:ocfs2-devel-request@oss.oracle.com?subject=help>
List-Subscribe: <http://oss.oracle.com/mailman/listinfo/ocfs2-devel>,
	<mailto:ocfs2-devel-request@oss.oracle.com?subject=subscribe>
Sender: ocfs2-devel-bounces@oss.oracle.com
Errors-To: ocfs2-devel-bounces@oss.oracle.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 12, 2009 at 11:17:58AM -0800, Joel Becker wrote:
> On Thu, Nov 12, 2009 at 09:10:43AM +0100, Ingo Molnar wrote:
> > 5 out of 8 places look buggy - i.e. more than 60% - a checkpatch warning 
> > would avoid real bugs here. (even ignoring the cleanliness effects of 
> > using proper error propagation)
> > 
> > Cc:-ed affected maintainers. The rightmost column are my observations. 
> > Below is the patch fixing these.
> 
> Acked-by: Joel Becker <joel.becker@oracle.com>

I take that back.  NAK.

Sorry, I read the code wrong.  This function is just a handler.
The caller, dlm_send_begin_reco_message(), expects the positive EAGAIN
as a non-error case.

Joel

-- 

Life's Little Instruction Book #337

	"Reread your favorite book."

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
