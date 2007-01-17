From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take33 10/10] kevent: Kevent based AIO (aio_sendfile()/aio_sendfile_path()).
Date: Wed, 17 Jan 2007 17:39:51 +0300
Message-ID: <20070117143950.GA19434@2ka.mipt.ru>
References: <11690154353959@2ka.mipt.ru> <11690154352501@2ka.mipt.ru> <20070117135142.GA24866@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Suparna Bhattacharya <suparna@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <20070117135142.GA24866@in.ibm.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 17, 2007 at 07:21:42PM +0530, Suparna Bhattacharya (suparna@in.ibm.com) wrote:
> 
> Since you are implementing new APIs here, have you considered doing an
> aio_sendfilev to be able to send a header with the data ?

It is doable, but why people do not like corking?
With Linux less than microsecond syscall overhead it is better and more
flexible solution, doesn't it?

I'm not saying - 'no, there will not be any *v variants', just getting
more info.

> Regards
> Suparna

-- 
	Evgeniy Polyakov
