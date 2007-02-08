From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: Network: convert network devices to use struct device instead of class_device
Date: Thu, 8 Feb 2007 12:29:12 -0500
Message-ID: <d120d5000702080929r7016de12k292add26a0a72291@mail.gmail.com>
References: <200702080400.l1840lFd002314@hera.kernel.org>
	 <45CB1AE6.9020707@garzik.org> <20070208074130.29df585f@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, "Greg KH" <greg@kroah.com>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423241AbXBHR3Q@vger.kernel.org>
In-Reply-To: <20070208074130.29df585f@oldman>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/8/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> On Thu, 08 Feb 2007 07:43:18 -0500
> Jeff Garzik <jeff@garzik.org> wrote:
>
> > Linux Kernel Mailing List wrote:
> > > Gitweb:     http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=43cb76d91ee85f579a69d42bc8efc08bac560278
> > > Commit:     43cb76d91ee85f579a69d42bc8efc08bac560278
> > > Parent:     2943ecf2ed32632473c06f1975db47a7aa98c10f
> > > Author:     Greg Kroah-Hartman <gregkh@suse.de>
> > > AuthorDate: Tue Apr 9 12:14:34 2002 -0700
> > > Committer:  Greg Kroah-Hartman <gregkh@suse.de>
> > > CommitDate: Wed Feb 7 10:37:11 2007 -0800
> > >
> > >     Network: convert network devices to use struct device instead of class_device
> > >
> > >     This lets the network core have the ability to handle suspend/resume
> > >     issues, if it wants to.
>
> It fixes a non-problem. I would like to see the network core suspend/resume
> proposal as well. Last time I examined doing network core suspend help,
> the problem was that the physical device suspend was called before the
> class device. It is not clear how this change would help.

If physical devices are registered before class devices then when
suspending class devices are naturally suspended first. It is still
not clear to me why we need to convert everythign to struct device, I
believe I've shown (with patches) that it is possible to integrate
struct class_device into PM framework and avoid reshuffling half of
the kernel code.

-- 
Dmitry
