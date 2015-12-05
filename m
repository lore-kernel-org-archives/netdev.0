From: Jens Axboe <axboe@fb.com>
Subject: Re: 4.4-rc3, KVM, br0 and instant hang
Date: Sat, 5 Dec 2015 10:32:44 -0700
Message-ID: <56631FBC.4030002@fb.com>
References: <22114.26609.457727.203801@quad.stoffel.home>
 <20151205162328.GA32532@quad.stoffel.home>
 <22115.8036.357755.548697@quad.stoffel.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jaxboe@fusionio.com>
To: John Stoffel <john@stoffel.org>,
	John Stoffel <john@quad.stoffel.home>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22115.8036.357755.548697@quad.stoffel.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/05/2015 10:31 AM, John Stoffel wrote:
>>>>>> "John" == John Stoffel <john@quad.stoffel.home> writes:
>
> John> On Fri, Dec 04, 2015 at 11:28:33PM -0500, John Stoffel wrote:
>>>
>>> Hi all,
>
>>> Anyway, if I try to boot up anything past the 4.2.6 kernel, the system
>>> locks up pretty quickly with an oops message that scrolls off the
>>> screen too far.  I've got some pictures which I'll attach in a bit,
>>> maybe they'll help.  So at first I thought it was something to do with
>>> bad kworker threads, or SCSI or SATA interactions, but as I tried to
>>> configure Netconsole to log to my beaglebone black SBC, I found out
>>> that if I compiled and installed 4.4-rc3, started the bridge up (br0),
>>> even started KVM, but did NOT start my VMs, the system was stable.
>
> I've now figured out that I can disable all my VMs from autostart, and
> the system will come up properly.  Then I can setup netconsole to use
> the br0 interface, do an  "echo t > sysrq" to confirm it's working,
> and start up the VMs.
>
> On my most recent bootup, I thought it was ok, since the VMs worked
> for a while (10 minutes) and I was starting to re-compile the kernel
> again to make more modules compiled in.  No luck, I got the following
> crash dump (partial) on my netconsole box.
>
> [ 1434.266524] ------------[ cut here ]------------
> [ 1434.266643] WARNING: CPU: 2 PID: 179 at block/blk-merge.c:435 blk_rq_map_sg+0x2d9/0x2eb()

This is fixed in current -git, as of a few days ago.

-- 
Jens Axboe
