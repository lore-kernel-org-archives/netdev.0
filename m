From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: qlcnic binary sysfs file abuse
Date: Thu, 25 Jul 2013 19:37:46 +0000
Message-ID: <0EA5B226BC5C7B45A71BF612AA8A019E355A3BD4@AVMB1.qlogic.org>
References: <20130707002949.GA15822@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Greg KH <gregkh@linuxfoundation.org>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Dept-Eng Linux Driver <Linux-Driver@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130707002949.GA15822@kroah.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Greg KH [mailto:gregkh@linuxfoundation.org]
> Sent: Saturday, July 06, 2013 5:30 PM
> To: Rajesh Borundia; Shahed Shaikh; Jitendra Kalsaria; Sony Chacko; Dept-Eng
> Linux Driver
> Cc: netdev; linux-kernel
> Subject: qlcnic binary sysfs file abuse
> 
> I was doing a kernel-wide audit on all of the binary sysfs files, and noticed a
> metric ton of them in the qlcnic driver.
> 
> So, any objection to me just deleting these entirely?  Or, if they really are
> needed, can I just move them to debugfs, which is where I think they should
> have been from the beginning?

Some applications are using these files, please move them to debugfs.

Thanks,
Sony
