From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m
	driver v2
Date: Tue, 2 Dec 2008 18:10:58 -0800
Message-ID: <200812021810.59279.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Johannes Berg <johannes@sipsolutions.net>,
	Patrick McHardy <kaber@trash.net>, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1227691434.git.inaky@linux.intel.com>
Content-Disposition: inline
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

On Wednesday 26 November 2008, Inaky Perez-Gonzalez wrote:
> Hi All
>
> This patchset (or the linux-wimax GIT tree at git.kernel.org) merges
> the WiMAX subsystem and driver for the Intel 2400m Wireless WiMAX
> connection to the tree. We'd like to get it in for the 2.6.29 merge
> window.
>

That was a lot of feedback, thanks guys.

I think I covered most of your concerns, please let me know. I still have
left to work on:

- replacing the ifinfo stuff with looking at the controller

- moving some of the sysfs files to debugfs

- moving to use dynamic_printk()

First two ones I plan to tackle ASAP. The dynamic_printk() stuff might take
longer and I was wondering if you would be ok with changing that post-29 in
case I were about to miss the merge window (got a few very busy weeks
ahead of me).

Once I am done tackling those two ones I'll update the trees in kernel.org
and repost a new set of patches.

Thanks,

-- 
Inaky
