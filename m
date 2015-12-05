From: "John Stoffel" <john@stoffel.org>
Subject: Re: 4.4-rc3, KVM, br0 and instant hang
Date: Sat, 5 Dec 2015 15:33:46 -0500
Message-ID: <22115.18986.538817.982478@quad.stoffel.home>
References: <22114.26609.457727.203801@quad.stoffel.home>
	<20151205162328.GA32532@quad.stoffel.home>
	<22115.8036.357755.548697@quad.stoffel.home>
	<56631FBC.4030002@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: John Stoffel <john@stoffel.org>,
	John Stoffel <john@quad.stoffel.home>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jaxboe@fusionio.com>
To: Jens Axboe <axboe@fb.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56631FBC.4030002@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "Jens" == Jens Axboe <axboe@fb.com> writes:

Jens> On 12/05/2015 10:31 AM, John Stoffel wrote:
>>>>>>> "John" == John Stoffel <john@quad.stoffel.home> writes:
>> 
John> On Fri, Dec 04, 2015 at 11:28:33PM -0500, John Stoffel wrote:
>>>> 
>> On my most recent bootup, I thought it was ok, since the VMs worked
>> for a while (10 minutes) and I was starting to re-compile the kernel
>> again to make more modules compiled in.  No luck, I got the following
>> crash dump (partial) on my netconsole box.
>> 
>> [ 1434.266524] ------------[ cut here ]------------
>> [ 1434.266643] WARNING: CPU: 2 PID: 179 at block/blk-merge.c:435 blk_rq_map_sg+0x2d9/0x2eb()

Jens> This is fixed in current -git, as of a few days ago.

Thanks!  I'll try that out and see how stable it is.  I assume it
doesn't matter if it's a deadline or cfq scheduler?

In any case, I see the pull in Linus' tree and I'm building a kernel
now to play with.

Thanks!
John
