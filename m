From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: Remaining BKL users, what to do
Date: Thu, 16 Sep 2010 22:26:24 +0100
Message-ID: <16843727-8A3D-48FF-9021-E0AD99C23E18@cam.ac.uk>
References: <201009161632.59210.arnd@arndb.de> <20100916150459.GA8437@quack.suse.cz>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Arnd Bergmann <arnd@arndb.de>, codalist@coda.cs.cmu.edu,
	autofs@linux.kernel.org, linux-media@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Anders Larsen <al@alarsen.net>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Andrew Hendry <andrew.hendry@gmail.com>
To: Jan Kara <jack@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100916150459.GA8437@quack.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 16 Sep 2010, at 16:04, Jan Kara wrote:
> On Thu 16-09-10 16:32:59, Arnd Bergmann wrote:
>> The big kernel lock is gone from almost all code in linux-next, this is
>> the status of what I think will happen to the remaining users:
> ...
>> fs/ncpfs:
>> 	Should be fixable if Petr still cares about it. Otherwise suggest
>> 	moving to drivers/staging if there are no users left.
>  I think some people still use this...

Yes, indeed.  Netware is still alive (unfortunately!) and ncpfs is used in a lot of Universities here in the UK at least (we use it about a thousand workstations and servers here at Cambridge University!).

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/
